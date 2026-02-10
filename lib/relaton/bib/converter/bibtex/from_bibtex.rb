module Relaton
  module Bib
    module Converter
      module Bibtex
        class FromBibtex
          # @param entry [BibTeX::Entry]
          def initialize(entry)
            @entry = entry
          end

          # @return [Relaton::Bib::ItemData]
          def transform # rubocop:disable Metrics/MethodLength
            ItemData.new(
              id: @entry.key,
              docidentifier: fetch_docid,
              fetched: fetch_fetched,
              type: fetch_type,
              title: fetch_title,
              contributor: fetch_contributor,
              date: fetch_date,
              place: fetch_place,
              note: fetch_note,
              relation: fetch_relation,
              extent: fetch_extent,
              edition: fetch_edition,
              series: fetch_series,
              source: fetch_link,
              language: fetch_language,
              classification: fetch_classification,
              keyword: fetch_keyword,
            )
          end

          private

          # @return [Array<Relaton::Bib::Docidentifier>]
          def fetch_docid # rubocop:disable Metrics/AbcSize
            docid = []
            docid << Docidentifier.new(content: @entry.isbn.to_s, type: "isbn") if @entry["isbn"]
            docid << Docidentifier.new(content: @entry.lccn.to_s, type: "lccn") if @entry["lccn"]
            docid << Docidentifier.new(content: @entry.issn.to_s, type: "issn") if @entry["issn"]
            docid
          end

          # @return [String, nil]
          def fetch_fetched
            ::Date.parse(@entry.timestamp.to_s) if @entry["timestamp"]
          end

          # @return [String]
          def fetch_type
            case @entry.type
            when :mastersthesis, :phdthesis then "thesis"
            when :conference then "inproceedings"
            when :misc then "standard"
            else @entry.type.to_s
            end
          end

          # @return [Array<Relaton::Bib::Place>]
          def fetch_place
            @entry["address"] ? [Place.new(formatted_place: @entry.address.to_s)] : []
          end

          # @return [Array<Relaton::Bib::Title>]
          def fetch_title
            title = []
            title << Title.new(type: "main", content: @entry.convert(:latex).title.to_s) if @entry["title"]
            title << Title.new(type: "main", content: @entry.convert(:latex).subtitle.to_s) if @entry["subtitle"]
            title
          end

          # @return [Array<Relaton::Bib::Contributor>]
          def fetch_contributor # rubocop:disable Metrics/AbcSize
            contribs = []
            fetch_person("author") { |c| contribs << c }
            fetch_person("editor") { |c| contribs << c }

            fetch_org(@entry["publisher"], "publisher") { |c| contribs << c }
            fetch_org(@entry["institution"], "distributor", "sponsor") { |c| contribs << c }
            fetch_org(@entry["organization"], "distributor", "sponsor") { |c| contribs << c }
            fetch_org(@entry["school"], "distributor", "sponsor") { |c| contribs << c }

            fetch_howpublished { |c| contribs << c }

            contribs
          end

          def fetch_howpublished(&_)
            return unless @entry["howpublished"]

            /\\publisher\{(?<name>.+)\},\\url\{(?<url>.+)\}/ =~ @entry.howpublished.to_s
            return unless name && url

            name.gsub!(/\{\\?([^\\]+)\}/, '\1')
            org = Organization.new(name: [TypedLocalizedString.new(content: name)], url: url)
            yield Contributor.new(
              organization: org,
              role: [Contributor::Role.new(type: "publisher")],
            )
          end

          # @param org [String, nil] organization name
          # @param type [String] role type
          # @param desc [String, nil] role description
          def fetch_org(org, type, desc = nil, &_)
            return unless org

            role_obj = Contributor::Role.new(type: type)
            role_obj.description = [LocalizedMarkedUpString.new(content: desc)] if desc
            yield Contributor.new(organization: Organization.new(name: [TypedLocalizedString.new(content: org.to_s)]), role: [role_obj])
          end

          # @param role [String] contributor role
          def fetch_person(role, &_) # rubocop:disable Metrics/AbcSize
            @entry[role]&.each do |name|
              parts = name.split ", "
              surname = LocalizedString.new(content: parts.first)
              fname = parts.size > 1 ? parts[1].split : []
              forename = fname.map { |fn| FullNameType::Forename.new(content: fn) }
              name = FullName.new(surname: surname, forename: forename)
              yield Contributor.new(
                person: Person.new(name: name),
                role: [Contributor::Role.new(type: role)],
              )
            end
          end

          # @return [Array<Relaton::Bib::Date>]
          def fetch_date
            date = []
            if @entry["year"]
              on = ::Date.new(@entry.year.to_i, @entry["month_numeric"]&.to_i || 1).to_s
              date << Bib::Date.new(type: "published", at: on)
            end

            if @entry["urldate"]
              date << Bib::Date.new(type: "accessed", at: ::Date.parse(@entry.urldate.to_s).to_s)
            end

            date
          end

          # @return [Array<Relaton::Bib::Note>]
          def fetch_note # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
            @entry.select do |k, _v|
              %i[annote howpublished comment note content].include? k
            end.reduce([]) do |mem, note|
              type = case note[0]
                    when :note then nil
                    when :content then "tableOfContents"
                    else note[0].to_s
                    end
              next mem if type == "howpublished" && note[1].to_s.match?(/^\\publisher\{.+\},\\url\{.+\}$/)

              mem << Note.new(type: type, content: note[1].to_s)
            end
          end

          # @return [Array<Relaton::Bib::Relation>]
          def fetch_relation
            return [] unless @entry["booktitle"]

            ttl = Title.new(type: "main", content: @entry.booktitle.to_s)
            [Relation.new(type: "partOf", bibitem: ItemData.new(title: [ttl]))]
          end

          # @return [Array<Relaton::Bib::Extent>]
          def fetch_extent # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
            locs = @entry.select do |k, _v|
              %i[chapter pages volume].include? k
            end.reduce([]) do |mem, loc|
              if loc[0] == :pages
                type = "page"
                from, to = loc[1].to_s.split "-"
              else
                type = loc[0].to_s
                from = loc[1].to_s
                to = nil
              end
              mem << Locality.new(type: type, reference_from: from, reference_to: to)
            end
            [Extent.new(locality: locs)]
          end

          # @return [Array<Relaton::Bib::Series>]
          def fetch_series # rubocop:disable Metrics/MethodLength
            series = []
            if @entry["journal"]
              series << Series.new(
                type: "journal",
                title: Title.new(content: @entry.journal.to_s),
                number: @entry["number"]&.to_s,
              )
            end

            if @entry["series"]
              title = Title.new content: @entry.series.to_s
              series << Series.new(title: title)
            end
            series
          end

          # @return [Array<Relaton::Bib::Uri>]
          def fetch_link # rubocop:disable Metrics/AbcSize
            link = []
            link << Uri.new(type: "src", content: @entry.url.to_s) if @entry["url"]
            link << Uri.new(type: "doi", content: @entry.doi.to_s) if @entry["doi"]
            link << Uri.new(type: "file", content: @entry.file2.to_s) if @entry["file2"]
            link
          end

          # @return [Array<String>]
          def fetch_language
            return [] unless @entry["language"]

            [Iso639[@entry.language.to_s].alpha2]
          end

          # @return [Array<Relaton::Bib::Docidentifier>]
          def fetch_classification
            cls = []
            cls << Docidentifier.new(type: "type", content: @entry["type"].to_s) if @entry["type"]
            if @entry["mendeley-tags"]
              cls << Docidentifier.new(type: "mendeley", content: @entry["mendeley-tags"].to_s)
            end
            cls
          end

          # @return [Array<Relaton::Bib::Keyword>]
          def fetch_keyword
            @entry["keywords"]&.split(/,\s?/)&.map do |kw|
              Keyword.new(taxon: [LocalizedString.new(content: kw)])
            end || []
          end

          # @return [Relaton::Bib::Edition, nil]
          def fetch_edition
            Edition.new(content: @entry["edition"].to_s) if @entry["edition"]
          end
        end
      end
    end
  end
end
