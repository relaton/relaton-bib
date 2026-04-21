module Relaton
  module Bib
    module Converter
      module BibXml
        class FromRfcxml # rubocop:disable Metrics/ClassLength
          include NamespaceHelper

          def initialize(reference)
            @reference = reference
          end

          def transform # rubocop:disable Metrics/MethodLength
            namespace::ItemData.new(
              docnumber: @reference.anchor,
              type: "standard",
              docidentifier: docidentifiers,
              status: status,
              language: ["en"],
              script: ["Latn"],
              source: source,
              title: title,
              formattedref: formattedref,
              abstract: abstract,
              contributor: contributor + workgroup_contributors,
              date: date,
              series: series,
              keyword: keyword,
              ext: ext,
            )
          end

          private

          # --- Source ---

          def source # rubocop:disable Metrics/AbcSize
            s = []
            if @reference.target
              s << Uri.new(type: "src",
                           content: @reference.target)
            end
            (@reference.format || []).each do |fr|
              s << Uri.new(type: fr.type, content: fr.target)
            end
            s
          end

          # --- Docidentifiers ---

          def docidentifiers
            draft_id = versioned_internet_draft_id
            ids = [create_docid(@reference.anchor, primary: draft_id.nil?)]
            ids << draft_id if draft_id
            ids + docid_from_series_info
          end

          def create_docid(id, primary: false) # rubocop:disable Metrics/MethodLength
            args = {}
            pref, num = id_to_pref_num(id)
            if RFCPREFIXES.include?(pref)
              args[:content] = "#{pref} #{num.sub(/^-?0+/, '')}"
              args[:type] = pubid_type(id)
            elsif %w[I-D draft].include?(pref)
              args[:content] = "draft-#{num}"
              args[:type] = "Internet-Draft"
            else
              args[:content] = pref ? "#{pref} #{num}" : id
              args[:type] = pubid_type(id)
            end
            args[:primary] = true if primary
            Docidentifier.new(**args)
          end

          def pubid_type(id)
            id_to_pref_num(id)&.first
          end

          PREF_NUM_RE = /^(?<pref>I-D|draft|3GPP|W3C|[A-Z]{2,})[._-]?(?<num>.+)/

          def id_to_pref_num(id)
            tn = PREF_NUM_RE.match id
            tn && tn.to_a[1..2]
          end

          def versioned_internet_draft_id
            si = internet_draft_series_info(@reference.front) ||
              internet_draft_series_info(@reference)
            return unless si

            Docidentifier.new(
              type: "Internet-Draft", content: si.value, primary: true,
            )
          end

          def internet_draft_series_info(parent)
            (parent.series_info || []).find { |si| si.name == "Internet-Draft" }
          end

          def docid_from_series_info # rubocop:disable Metrics/CyclomaticComplexity
            front_si = @reference.front.series_info || []
            ref_si = @reference.series_info || []
            (front_si + ref_si).reduce([]) do |acc, s|
              next acc unless s.name.casecmp("doi").zero?

              acc << Docidentifier.new(type: "DOI", content: s.value)
            end
          end

          # --- Status ---

          def status # rubocop:disable Metrics/CyclomaticComplexity
            si = @reference.front.series_info&.find(&:status) ||
              @reference.series_info&.find(&:status)
            return unless si

            stage = Status::Stage.new(content: si.status)
            Status.new(stage: stage)
          end

          # --- Title / Formattedref ---

          def title
            return [] unless @reference.front.title

            [Title.new(content: @reference.front.title.content, language: "en",
                       script: "Latn")]
          end

          def formattedref
            return if @reference.front.title

            Formattedref.new(content: @reference.anchor)
          end

          # --- Abstract ---

          def abstract
            return [] unless @reference.front.abstract&.t

            @reference.front.abstract.t.map do |t|
              Abstract.new(content: t.content.join, language: "en", script: "Latn")
            end
          end

          # --- Contributors ---

          def contributor
            (@reference.front.author || []).reduce([]) do |acc, author|
              p = person(author)
              o = organization(author)
              next acc unless p || o

              args = { role: [contributor_role(author)] }
              if p
                args[:person] = p
              else
                args[:organization] = o
              end
              acc << Contributor.new(**args)
            end
          end

          def contributor_role(author)
            type = author.role || "author"
            Contributor::Role.new(type: type)
          end

          # --- Person ---

          def person(author)
            return unless author.fullname || author.surname

            Person.new(
              name: person_name(author),
              affiliation: person_affiliation(author),
              address: person_address(author),
              phone: contact_phone(author),
              email: contact_email(author),
              uri: contact_uri(author),
            )
          end

          def person_name(author)
            FullName.new(
              completename: LocalizedString.new(content: author.fullname,
                                                language: "en"),
              formatted_initials: person_initials(author),
              forename: person_forename(author),
              surname: LocalizedString.new(content: author.surname,
                                           language: "en"),
            )
          end

          def person_initials(author)
            return unless author.initials

            LocalizedString.new(content: author.initials, language: "en")
          end

          def person_forename(author)
            return [] unless author.initials

            author.initials.split(/\.-?\s?|\s/).map do |i|
              FullNameType::Forename.new(initial: i, language: "en")
            end
          end

          def person_affiliation(author)
            org = organization(author)
            return [] unless org

            [Affiliation.new(organization: org)]
          end

          # --- Organization ---

          def organization(author) # rubocop:disable Metrics/AbcSize
            org = author.organization
            return if org.nil? || org.content.empty?

            name = ORGNAMES[org.content.join] || org.content.join
            orgname = TypedLocalizedString.new(content: name, language: "en")
            abbrev = LocalizedString.new(content: org.abbrev, language: "en") if org.abbrev
            Organization.new(
              name: [orgname], abbreviation: abbrev,
              address: org_address(author), phone: contact_phone(author),
              email: contact_email(author), uri: contact_uri(author)
            )
          end

          # --- Address ---

          def person_address(author)
            transform_address(author.address)
          end

          def org_address(author)
            transform_address(author.address)
          end

          def transform_address(address) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
            return [] unless address&.postal

            postal = address.postal
            transform_address_args(
              street: postal.street || [],
              city: postal.city || [],
              region: postal.region || [],
              country: postal.country || [],
              code: postal.code || [],
              postal_line: postal.postal_line || [],
            )
          end

          def transform_address_args(**args)
            i = 0
            addrs = []
            while args.values.any? { |v| v[i] }
              addrs << create_address(**args.transform_values { |v| v[i] })
              i += 1
            end
            addrs
          end

          def create_address(**args) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
            street = []
            street << args[:street]&.content if args[:street]
            Address.new(
              street: street,
              city: args[:city]&.content,
              state: args[:region]&.content,
              country: args[:country]&.content,
              postcode: args[:code]&.content,
              formatted_address: args[:postal_line]&.content,
            )
          end

          # --- Contacts ---

          def contact_phone(author)
            return [] unless author.address&.phone

            [Phone.new(content: author.address.phone.content)]
          end

          def contact_email(author)
            return [] unless author.address&.email

            author.address.email.map(&:content)
          end

          def contact_uri(author)
            return [] unless author.address&.uri

            [Uri.new(content: author.address.uri.content)]
          end

          # --- Date ---

          def date # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            dt = @reference.front&.date
            return [] unless dt && (dt.year || dt.month || dt.day)

            dparts = [dt.year, month_to_num(dt.month),
                      dt.day].compact.reject(&:empty?)
            at = dt.content.empty? ? dparts.join("-") : dt.content
            [Date.new(type: "published", at: at)]
          end

          def month_to_num(month)
            return unless month

            ::Date::MONTHNAMES.index(month.capitalize).to_s
          end

          # --- Series ---

          def series # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize
            ref_si = @reference.series_info || []
            front_si = @reference.front.series_info || []
            (ref_si + front_si).map do |si|
              next if si.name == "DOI" || si.stream || si.status

              t = Title.new(content: si.name, language: "en", script: "Latn")
              Series.new(title: [t], number: si.value, type: "main")
            end.compact
          end

          # --- Keyword ---

          def keyword
            (@reference.front.keyword || []).map do |kw|
              vocab = LocalizedString.new(content: kw.content, language: "en",
                                          script: "Latn")
              Keyword.new(vocab: vocab)
            end
          end

          # --- Workgroup Contributors ---

          def workgroup_contributors
            return [] unless @reference.front.workgroup

            @reference.front.workgroup.map do |wg|
              Contributor.new(
                role: [Contributor::Role.new(
                  type: "author",
                  description: [LocalizedMarkedUpString.new(content: "committee")],
                )],
                organization: Organization.new(
                  subdivision: [Subdivision.new(
                    type: "workgroup",
                    name: [TypedLocalizedString.new(content: wg.content)],
                  )],
                ),
              )
            end
          end

          # --- Ext ---

          def ext
            dt = doctype
            return unless dt

            namespace::Ext.new doctype: dt, flavor: falvor
          end

          def doctype
            type = case @reference.anchor
                   when /I-D/ then "internet-draft"
                   when /IEEE/ then "ieee"
                   else "rfc"
                   end
            namespace::Doctype.new content: type
          end

          def falvor = "ietf"
        end
      end
    end
  end
end
