module Relaton
  module Bib
    module HashParserV1
      extend self
      # @param args [Hash]
      # @return [Hash]
      def hash_to_bib(args) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        return nil unless args.is_a?(Hash)

        ret = Marshal.load(Marshal.dump(symbolize(args))) # deep copy
        ret[:fetched] &&= ::Date.parse(ret[:fetched])
        ret[:schema_version] = ret.delete(:"schema-version") if ret[:"schema-version"]
        title_hash_to_bib(ret)
        link_hash_to_bib(ret)
        language_hash_to_bib(ret)
        script_hash_to_bib(ret)
        dates_hash_to_bib(ret)
        docid_hash_to_bib(ret)
        version_hash_to_bib(ret)
        biblionote_hash_to_bib(ret)
        abstract_hash_to_bib(ret)
        formattedref_hash_to_bib(ret)
        docstatus_hash_to_bib(ret)
        contributors_hash_to_bib(ret)
        edition_hash_to_bib(ret)
        copyright_hash_to_bib(ret)
        relations_hash_to_bib(ret)
        series_hash_to_bib(ret)
        medium_hash_to_bib(ret)
        place_hash_to_bib(ret)
        extent_hash_to_bib(ret)
        size_hash_to_bib(ret)
        accesslocation_hash_to_bib(ret)
        classification_hash_to_bib(ret)
        validity_hash_to_bib(ret)
        keyword_hash_to_bib(ret)
        ret[:license] = Relaton.array(ret[:license])
        ext_has_to_bib ret
        ret
      end

      def ext_has_to_bib(ret)
        ret[:ext] ||= {}
        doctype_hash_to_bib ret
        ret[:ext][:subdoctype] = ret.delete(:subdoctype) if ret[:subdoctype]
        ret[:ext][:flavor] ||= flavor(ret)
        editorialgroup_hash_to_bib ret
        ics_hash_to_bib ret
        structuredidentifier_hash_to_bib ret
        ret[:ext] = Bib::Ext.new(**ret[:ext])
      end

      def flavor(ret)
        return unless ret[:docid]

        docid = ret[:docidentifier].find(&:primary)
        return unless docid

        docid.type.downcase
      end

      def keyword_hash_to_bib(ret)
        ret[:keyword] = Relaton.array(ret[:keyword]).map do |keyword|
          Bib::Keyword.new taxon: [localizedstring(keyword)]
        end
      end

      def extent_hash_to_bib(ret)
        return unless ret[:extent]

        ret[:extent] = Relaton.array(ret[:extent]).map do |e|
          Relaton::Bib::Extent.new  locality: locality(e[:locality]),
                                    locality_stack: locality_stack(e[:locality_stack])
        end
      end

      def locality(locality)
        Relaton.array(locality).map { |l| Bib::Locality.new(**l) }
      end

      def locality_stack(locality_stack)
        Relaton.array(locality_stack).map { |l| Bib::LocalityStack.new locality: locality(l[:locality]) }
      end

      def size_hash_to_bib(ret)
        return unless ret[:size]

        ret[:size] = Relaton.array(ret[:size])
        value = ret[:size]&.map do |val|
          val[:content] = val.delete(:value)
          Bib::Size::Value.new(**val)
        end
        ret[:size] = Bib::Size.new(value: value)
      end

      def title_hash_to_bib(ret)
        # return unless ret[:title]

        # ret[:title] = Relaton.array(ret[:title]).reduce(Bib::TitleCollection.new) do |m, t|
        #   m << (t.is_a?(Hash) ? Bib::Title.new(**t) : Bib::Title.new(content: t))
        # end
        ret[:title] &&= title_collection(ret[:title])
      end

      def language_hash_to_bib(ret)
        return unless ret[:language]

        ret[:language] = Relaton.array(ret[:language])
      end

      def script_hash_to_bib(ret)
        return unless ret[:script]

        ret[:script] = Relaton.array(ret[:script])
      end

      def abstract_hash_to_bib(ret)
        ret[:abstract] &&= Relaton.array(ret[:abstract]).map do |a|
          localized_marked_up_string a
        end
      end

      def link_hash_to_bib(ret)
        return unless ret[:link]

        ret[:source] = Relaton.array(ret[:link]).map do |l|
          Bib::Uri.new(**l)
        end
      end

      def place_hash_to_bib(ret)
        ret[:place] &&= Relaton.array(ret[:place]).map { |pl| create_place(pl) }
      end

      def create_place(place)
        if place.is_a?(String)
          Bib::Place.new(formatted_place: place)
        else
          place[:region] &&= create_region(place[:region])
          place[:country] &&= create_region(place[:country])
          Bib::Place.new(**place)
        end
      end

      def create_region(region)
        Relaton.array(region).map do |r|
          r[:content] ||= r.delete(:name)
          r[:iso] ||= r.delete(:code)
          Bib::Place::RegionType.new(**r)
        end
      end

      def accesslocation_hash_to_bib(ret)
        return unless ret[:accesslocation]

        ret[:accesslocation] = Relaton.array(ret[:accesslocation])
      end

      def dates_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize
        ret[:date] &&= Relaton.array(ret[:date]).map.with_index do |d, i|
          # value is synonym of on: it is reserved word in YAML
          if d[:value]
            ret[:date][i][:at] ||= d[:value]
            ret[:date][i].delete(:value)
            Bib::Date.new(**ret[:date][i])
          end
        end
      end

      def docid_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize
        return unless ret[:docid]

        ret[:docidentifier] = Relaton.array(ret[:docid]).map do |id|
          id[:type] ||= id[:id].match(/^\w+(?=\s)/)&.to_s
          id[:content] = id[:id]
          create_docid(**id)
        end
      end

      def create_docid(**args)
        Bib::Docidentifier.new(**args)
      end

      def version_hash_to_bib(ret)
        return unless ret[:version]

        ret[:version] = Relaton.array(ret[:version]).map do |v|
          v[:revision_date] &&= ::Date.parse(v[:revision_date])
          Bib::Version.new(**v)
        end
      end

      def biblionote_hash_to_bib(ret)
        ret[:note] = Relaton.array(ret.delete(:biblionote)).map do |n|
          n.is_a?(String) ? Bib::Note.new(content: n) : Bib::Note.new(**n)
        end
      end

      def formattedref_hash_to_bib(ret)
        ret[:formattedref] &&
          ret[:formattedref] = formattedref(ret[:formattedref])
      end

      def docstatus_hash_to_bib(ret)
        ret[:docstatus] && ret[:status]= Bib::Status.new(
          stage: stage(ret[:docstatus][:stage]),
          substage: stage(ret[:docstatus][:substage]),
          iteration: ret[:docstatus][:iteration],
        )
      end

      # @param stg [Hash]
      # @return [Relaton::Bib::DocumentStatus::Stage]
      def stage(stg)
        return unless stg

        args = stg.is_a?(String) ? { content: stg } : stg
        args[:content] ||= args.delete(:value)
        Bib::Status::Stage.new(**args)
      end

      def contributors_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,Metrics/PerceivedComplexity
        ret[:contributor] &&= Relaton.array(ret[:contributor]).map.with_index do |c, i|
          roles = Relaton.array(ret[:contributor][i][:role]).map do |r|
            if r.is_a? Hash
              desc = Relaton.array(r[:description]).map { |d| localized_marked_up_string d }
              Bib::Contributor::Role.new(type: r[:type], description: desc)
            else
              Bib::Contributor::Role.new(type: r)
            end
          end
          c[:role] = roles
          (c[:person] &&= create_person(c[:person])) ||
            (c[:organization] &&= create_organization(c[:organization]))
          Bib::Contributor.new(**c)
        end
      end

      def edition_hash_to_bib(ret)
        ret[:edition] &&= Bib::Edition.new(**ret[:edition])
      end

      def create_organization(org)
        return nil if org.nil?

        Bib::Organization.new(**org_hash_to_bib(org))
      end

      def org_hash_to_bib(org) # rubocop:disable Metrics/AbcSize
        org[:identifier] = create_org_identifier(org[:identifier])
        org[:subdivision] = create_org_subdivision(org[:subdivision])
        org[:address] = address_hash_to_bib(org[:contact])
        org[:phone] = phone_hash_to_bib(org[:contact])
        org[:email] = email_hash_to_bib(org[:contact])
        org[:uri] = uri_hash_to_bib(org[:contact] || org)
        org[:logo] = Bib::Logo.new image: Bib::Image.new(**org[:logo][:image]) if org[:logo]
        org[:name] = typed_localized_string(org[:name])
        org[:abbreviation] &&= localizedstring(org[:abbreviation])
        org
      end

      def create_org_identifier(identifier)
        Relaton.array(identifier).map do |id|
          Bib::Organization::Identifier.new(type: id[:type], content: id[:id])
        end
      end

      def create_org_subdivision(subdivision)
        Relaton.array(subdivision).map do |sub|
          if sub.is_a? String
            orgname = Bib::TypedLocalizedString.new(content: sub)
            Bib::Subdivision.new(name: [orgname])
          elsif sub.is_a?(Hash) && sub[:content]
            sub[:name] = sub.delete(:content)
            Bib::Subdivision.new(**org_hash_to_bib(sub))
          end
        end.compact
      end

      def typed_localized_string(typed_strs)
        Relaton.array(typed_strs).map do |args|
          if args.is_a? String
            Bib::TypedLocalizedString.new(content: args)
          elsif args.is_a? Hash
            Bib::TypedLocalizedString.new(**args)
          end
        end
      end

      # def create_org_name(name)
      #   Relaton.array(name).map do |nm|
      #     if nm.is_a?(Hash)
      #       Bib::Organization::Name.new(**nm)
      #     else
      #       Bib::Organization::Name.new(content: nm)
      #     end
      #   end
      # end

      def create_person(person)
        Bib::Person.new(
          name: fullname_hash_to_bib(person),
          credential: Relaton.array(person[:credential]),
          affiliation: affiliation_hash_to_bib(person),
          address: address_hash_to_bib(person[:contact]),
          phone: phone_hash_to_bib(person[:contact]),
          email: email_hash_to_bib(person[:contact]),
          uri: uri_hash_to_bib(person[:contact]),
          identifier: person_identifiers_hash_to_bib(person),
        )
      end

      def fullname_hash_to_bib(person) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        n = person[:name]
        fname = given_hash_to_bib n[:given] || n # `n` is for backward compatibility
        Bib::FullName.new(
          abbreviation: localizedstring(n[:abbreviation]),
          forename: fname,
          formatted_initials: localizedstring(n.dig(:given, :formatted_initials)),
          addition: Relaton.array(n[:addition])&.map { |f| localizedstring(f) },
          prefix: Relaton.array(n[:prefix])&.map { |f| localizedstring(f) },
          surname: localizedstring(n[:surname]),
          completename: localizedstring(n[:completename]),
        )
      end

      def given_hash_to_bib(given)
        return unless given

        Relaton.array(given[:forename])&.map { |f| forename_hash_to_bib(f) }
      end

      def forename_hash_to_bib(fname)
        case fname
        when Hash
          lang_scrip_array_to_string fname
          FullNameType::Forename.new(**fname)
        when String then FullNameType::Forename.new(content: fname)
        end
      end

      def person_identifiers_hash_to_bib(person)
        Relaton.array(person[:identifier])&.map do |a|
          Bib::Person::Identifier.new(type: a[:type], content: a[:id])
        end
      end

      def affiliation_hash_to_bib(person) # rubocop:disable Metrics/AbcSize
        return [] unless person[:affiliation]

        Relaton.array(person[:affiliation]).map do |a|
          a[:description] = Relaton.array(a[:description]).map do |d|
            localized_marked_up_string d
          end
          Bib::Affiliation.new(
            organization: create_organization(a[:organization]),
            description: a[:description], name: localizedstring(a[:name])
          )
        end
      end

      def address_hash_to_bib(contact)
        Relaton.array(contact).reduce([]) do |a, c|
          next a unless c[:address]

          a << create_address(c[:address])
        end
      end

      def phone_hash_to_bib(contact)
        Relaton.array(contact).reduce([]) do |a, c|
          next a unless c[:phone]

          c[:type] ||= "work"
          a << Bib::Phone.new(type: c[:type], content: c[:phone])
        end
      end

      def email_hash_to_bib(contact)
        Relaton.array(contact).reduce([]) do |a, c|
          next a unless c[:email]

          a << c[:email]
        end
      end

      def uri_hash_to_bib(contact)
        Relaton.array(contact).reduce([]) do |a, c|
          next a unless c[:uri] || c[:url]

          a << Bib::Uri.new(content: c[:uri] || c[:url])
        end
      end

      def contacts_hash_to_bib(entity) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
        return [] unless entity[:contact]

        Relaton.array(entity[:contact]).map do |a|
          type, value = a.reject { |k, _| k == :type }.flatten
          case type
          when :street, :city, :state, :country, :postcode # it's for old version compatibility, should be removed in the future
            a[:street] = Relaton.array(a[:street])
            Bib::Address.new(**a)
          when :address then create_address(a[:address])
          when :phone, :email, :uri
            Bib::Contact.new(type: type.to_s, value: value, subtype: a[:type])
          else # it's for old version compatibility, should be removed in the future
            Bib::Contact.new(**a)
          end
        end
      end

      def create_address(adr)
        if adr.is_a?(Hash)
          adr[:street] = Relaton.array(adr[:street])
          Bib::Address.new(**adr)
        else
          Bib::Address.new(formatted_address: adr)
        end
      end

      # @param ret [Hash]
      def copyright_hash_to_bib(ret)
        ret[:copyright] &&= Relaton.array(ret[:copyright]).map do |c|
          c[:owner] = Relaton.array(c[:owner]).map do |o|
            create_contribution_info(o)
          end
          Bib::Copyright.new(**c)
        end
      end

      def create_contribution_info(contrib)
        if contrib[:surname] || contrib[:completename]
          Bib::ContributionInfo.new person: create_person(contrib)
        else
          Bib::ContributionInfo.new organization: create_organization(contrib)
        end
      end

      # @param ret [Hash]
      def relations_hash_to_bib(ret) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        return unless ret[:relation]

        ret[:relation] &&= Relaton.array(ret[:relation]).map do |rel|
          rel[:description] = LocalizedMarkedUpString.new(**rel[:description]) if rel[:description]
          relation_bibitem_hash_to_bib(rel)
          relation_locality_hash_to_bib(rel)
          relation_locality_stack_hash_to_bib(rel)
          relaton_source_locality_stack_hash_to_bib(rel)
          relation_source_locality_hash_to_bib(rel)
          Bib::Relation.new(**rel)
        end
      end

      # @param rel [Hash] relation
      def relation_bibitem_hash_to_bib(rel)
        if rel[:bibitem]
          rel[:bibitem] = bib_item hash_to_bib(rel[:bibitem])
        else
          Util.warn "Bibitem missing: `#{rel}`"
          rel[:bibitem] = nil
        end
      end

      # @param item_hash [Hash]
      # @return [Relaton::Bib::Item]
      def bib_item(item_hash)
        Bib::ItemData.new(**item_hash)
      end

      # @param rel [Hash] relation
      # @return [Relaton::Bib::LocalityStack]
      def relation_locality_hash_to_bib(rel)
        return unless rel[:locality]&.any?

        rel[:locality] = Relaton.array(rel[:locality]).map do |bl|
          Bib::Locality.new(**bl)
        end
      end

      def relation_locality_stack_hash_to_bib(rel)
        return unless rel[:locality_stack]&.any?

        rel[:locality_stack] = Relaton.array(rel[:locality_stack]).map do |ls|
          Bib::LocalityStack.new locality: relation_locality_hash_to_bib(ls)
        end
      end

      # def locality_locality_stack(lls)
      #   if lls[:locality_stack]
      #     RelatonBib.array(lls[:locality_stack]).map do |lc|
      #       l = lc[:locality] || lc
      #       Locality.new(l[:type], l[:reference_from], l[:reference_to])
      #     end
      #   else
      #     [Locality.new(lls[:type], lls[:reference_from], lls[:reference_to])]
      #   end
      # end

      # @param rel [Hash] relation
      def relation_source_locality_hash_to_bib(rel)
        rel[:source_locality] = Relaton.array(rel[:source_locality]).map do |loc|
          Bib::Locality.new(**loc)
        end
      end

      def relaton_source_locality_stack_hash_to_bib(rel) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
        sls = Relaton.array(rel[:source_locality_stack])
        Relaton.array(rel[:source_locality]).each do |loc|
          sls << Relaton.array(loc[:source_locality_stack]) if loc[:source_locality_stack]
        end

        case rel[:source_locality]
        when Hash then rel[source_locality].delete(:source_locality_stack)
        when Array then rel[:source_locality].delete_if { |loc| loc[:source_locality_stack] }
        end

        rel[:source_locality_stack] = sls.map do |loc|
          SourceLocalityStack.new source_locality: relation_source_locality_hash_to_bib(source_locality: loc)
        end
      end

      # @param ret [Hash]
      def series_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        ret[:series] &&= Relaton.array(ret[:series]).map do |s|
          s[:formattedref] && s[:formattedref] = formattedref(s[:formattedref])
          s[:title] &&= title_collection(s[:title])
          s[:place] &&= create_place(s[:place])
          s[:abbreviation] &&= localizedstring(s[:abbreviation])
          s[:from] &&= ::Date.parse(s[:from])
          s[:to] &&= ::Date.parse(s[:to])
          Bib::Series.new(**s)
        end
      end

      #
      # @param title [Hash, Strinbg, Array<Hash, String>]
      #
      # @return [Relaton::Bib::TitleCollection]
      #
      def title_collection(title)
        Relaton.array(title).map do |t|
          if t.is_a?(Hash)
            lang_scrip_array_to_string t
            Bib::Title.new(**t)
          elsif t.is_a?(String)
            Bib::Title.new(content: t)
          end
        end
      end

      # @param ret [Hash]
      def medium_hash_to_bib(ret)
        ret[:medium] = Bib::Medium.new(**ret[:medium]) if ret[:medium]
      end

      # @param ret [Hash]
      def classification_hash_to_bib(ret)
        if ret[:classification]
          ret[:classification] = Relaton.array(ret[:classification]).map do |cls|
            cls[:content] ||= cls.delete(:value)
            Docidentifier.new(**cls)
          end
        end
      end

      # @param ret [Hash]
      def validity_hash_to_bib(ret)
        return unless ret[:validity]

        b = parse_validity_time(ret[:validity], :begins)
        e = parse_validity_time(ret[:validity], :ends)
        r = parse_validity_time(ret[:validity], :revision)
        ret[:validity] = Bib::Validity.new(begins: b, ends: e, revision: r)
      end

      def parse_validity_time(val, period)
        t = val[period]&.to_s
        return unless t

        p = period == :ends ? -1 : 1
        case t
        when /^\d{4}$/
          ::Date.new(t.to_i, p, p).to_time
        when /^(?<year>\d{4})-(?<month>\d{1,2})$/
          ::Date.new($~[:year].to_i, $~[:month].to_i, p).to_time
        else ::Date.parse t
        end
      end

      # @param ret [Hash]
      def editorialgroup_hash_to_bib(ret)
        eg = ret.dig(:ext, :editorialgroup) || ret[:editorialgroup] # @todo remove ret[:editorialgroup] in the future
        return unless eg

        technical_committee = Relaton.array(eg).map do |wg|
          wg[:content] ||= wg.delete(:name)
          # Bib::TechnicalCommittee.new
          Bib::WorkGroup.new(**wg)
        end
        ret[:ext][:editorialgroup] = Bib::EditorialGroup.new technical_committee: technical_committee
      end

      # @param ret [Hash]
      def ics_hash_to_bib(ret)
        ics = ret.dig(:ext, :ics) || ret[:ics] # @todo remove ret[:ics] in the future
        return unless ics

        ret[:ext][:ics] = Relaton.array(ics).map { |item| Bib::ICS.new(**item) }
      end

      # @param ret [Hash]
      def structuredidentifier_hash_to_bib(ret)
        struct_id = ret.dig(:ext, :structuredidentifier) || ret[:structuredidentifier] # @todo remove ret[:structuredidentifier] in the future
        return unless struct_id

        sids = Relaton.array(struct_id).map do |si|
          si[:agency] = Relaton.array si[:agency]
          si[:klass] = si.delete(:class)
          Bib::StructuredIdentifier.new(**si)
        end
        ret[:ext][:structuredidentifier] = sids
      end

      # @param ogj [Hash, Array, String]
      # @return [Hash, Array, String]
      def symbolize(obj)
        case obj
        when Hash
          obj.reduce({}) do |memo, (k, v)|
            memo[k.to_sym] = symbolize(v)
            memo
          end
        when Array then obj.reduce([]) { |memo, v| memo << symbolize(v) }
        else obj
        end
      end

      # @param lst [Hash, Array<Relaton::Bib::LocalizedString>, String]
      # @return [Relaton::Bib::LocalizedString]
      def localizedstring(lst)
        return unless lst

        if lst.is_a?(Hash)
          lang_scrip_array_to_string lst
          Bib::LocalizedString.new(**lst)
        else Bib::LocalizedString.new(content: lst)
        end
      end

      def lang_scrip_array_to_string(lst)
        lst[:language] = lst[:language][0] if lst[:language].is_a?(Array)
        lst[:script] = lst[:script][0] if lst[:script].is_a?(Array)
      end

      def localized_marked_up_string(lst)
        return unless lst

        if lst.is_a?(Hash)
          lang_scrip_array_to_string lst
          LocalizedMarkedUpString.new(**lst)
        else LocalizedMarkedUpString.new(content: lst)
        end
      end

      # @param frf [Hash, String]
      # @return [Relaton::Bib::Formattedref]
      def formattedref(frf)
        if frf.is_a?(Hash)
          # Relaton::Bib::Formattedref.new(**frf)
          frf[:content]
        else
          # Relaton::Bib::Formattedref.new(content: frf)
          frf
        end
      end

      def doctype_hash_to_bib(ret)
        doctype = ret.dig(:ext, :doctype) || ret[:doctype] # @todo remove ret[:doctype] in the future
        return unless doctype

        ret[:ext][:doctype] = create_doctype(doctype)
      end

      def create_doctype(args)
        if args.is_a?(String)
          Bib::Doctype.new type: args
        else
          args[:content] = args.delete(:type)
          Bib::Doctype.new(**args)
        end
      end
    end
  end
end
