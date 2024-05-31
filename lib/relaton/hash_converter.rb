module Relaton
  module HashConverter
    extend self
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize

    # @param args [Hash]
    # @return [Hash]
    def hash_to_bib(args)
      return nil unless args.is_a?(Hash)

      ret = Marshal.load(Marshal.dump(symbolize(args))) # deep copy
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
      # ret[:keyword] = Relaton.array(ret[:keyword])
      ret[:license] = Relaton.array(ret[:license])
      editorialgroup_hash_to_bib ret
      ics_hash_to_bib ret
      structuredidentifier_hash_to_bib ret
      doctype_hash_to_bib ret
      ret
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def keyword_hash_to_bib(ret)
      ret[:keyword] = Relaton.array(ret[:keyword]).map do |keyword|
        localizedstring keyword
      end
    end

    def extent_hash_to_bib(ret)
      return unless ret[:extent]

      ret[:extent] = Relaton.array(ret[:extent]).map do |e|
        locality e
        # ret[:extent][i] = Locality.new(e[:type], e[:reference_from],
        #                                       e[:reference_to])
      end
    end

    def locality(loc)
      if loc[:locality_stack]
        LocalityStack.new(loc[:locality_stack].map { |l| locality(l) })
      else
        l = loc[:locality]
        Locality.new(l[:type], l[:reference_from], l[:reference_to])
      end
    end

    def size_hash_to_bib(ret)
      return unless ret[:size]

      ret[:size] = Relaton.array(ret[:size])
      size = ret[:size]&.map do |val|
        BibliographicSize::Value.new(**val)
      end
      ret[:size] = BibliographicSize.new(size)
    end

    def title_hash_to_bib(ret)
      return unless ret[:title]

      ret[:title] = Relaton.array(ret[:title])
        .reduce(TypedTitleStringCollection.new) do |m, t|
        if t.is_a?(Hash) then m << TypedTitleString.new(**t)
        else
          m + TypedTitleString.from_string(t)
        end
      end
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
      return unless ret[:abstract]

      ret[:abstract] = Relaton.array(ret[:abstract]).map do |a|
        a.is_a?(String) ? FormattedString.new(content: a) : a
      end
    end

    def link_hash_to_bib(ret)
      return unless ret[:link]

      ret[:link] = Relaton.array(ret[:link])
    end

    def place_hash_to_bib(ret)
      return unless ret[:place]

      ret[:place] = Relaton.array(ret[:place]).map do |pl|
        pl.is_a?(String) ? Place.new(name: pl) : Place.new(**pl)
      end
    end

    def accesslocation_hash_to_bib(ret)
      return unless ret[:accesslocation]

      ret[:accesslocation] = Relaton.array(ret[:accesslocation])
    end

    def dates_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize
      return unless ret[:date]

      ret[:date] = Relaton.array(ret[:date])
      ret[:date].each_with_index do |d, i|
        # value is synonym of on: it is reserved word in YAML
        if d[:value]
          ret[:date][i][:on] ||= d[:value]
          ret[:date][i].delete(:value)
        end
      end
    end

    def docid_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize
      return unless ret[:docid]

      ret[:docid] = Relaton.array(ret[:docid]).map do |id|
        id[:type] ||= id[:id].match(/^\w+(?=\s)/)&.to_s
        create_docid(**id)
      end
    end

    def create_docid(**args)
      DocumentIdentifier.new(**args)
    end

    def version_hash_to_bib(ret)
      return unless ret[:version]

      ret[:version] = Relaton.array(ret[:version]).map do |v|
        Item::Version.new(v[:revision_date], v[:draft])
      end
    end

    def biblionote_hash_to_bib(ret) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      return unless ret[:biblionote]

      ret[:biblionote] = Relaton.array(ret[:biblionote])
        .reduce(BiblioNoteCollection.new([])) do |mem, n|
        mem <<  if n.is_a?(String) then BiblioNote.new content: n
                else BiblioNote.new(**n)
                end
      end
    end

    def formattedref_hash_to_bib(ret)
      ret[:formattedref] &&
        ret[:formattedref] = formattedref(ret[:formattedref])
    end

    def docstatus_hash_to_bib(ret)
      ret[:docstatus] && ret[:docstatus] = DocumentStatus.new(
        stage: stage(ret[:docstatus][:stage]),
        substage: stage(ret[:docstatus][:substage]),
        iteration: ret[:docstatus][:iteration],
      )
    end

    # @param stg [Hash]
    # @return [Relaton::Bib::DocumentStatus::Stage]
    def stage(stg)
      return unless stg

      args = stg.is_a?(String) ? { value: stg } : stg
      DocumentStatus::Stage.new(**args)
    end

    def contributors_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,Metrics/PerceivedComplexity
      return unless ret[:contributor]

      ret[:contributor] = Relaton.array(ret[:contributor])
      ret[:contributor]&.each_with_index do |c, i|
        roles = Relaton.array(ret[:contributor][i][:role]).map do |r|
          if r.is_a? Hash
            desc = Relaton.array(r[:description]).map { |d| d.is_a?(String) ? d : d[:content] }
            { type: r[:type], description: desc }
          # elsif r.is_a? Array
          #   { type: r[0], description: r.fetch(1) }
          else
            { type: r }
          end
        end
        ret[:contributor][i][:role] = roles
        ret[:contributor][i][:entity] = if c[:person]
                                          person_hash_to_bib(c[:person])
                                        else
                                          org_hash_to_bib(c[:organization])
                                        end
        ret[:contributor][i].delete(:person)
        ret[:contributor][i].delete(:organization)
      end
    end

    def org_hash_to_bib(org) # rubocop:disable Metrics/AbcSize
      return nil if org.nil?

      org[:identifier] = Relaton.array(org[:identifier])&.map do |a|
        OrgIdentifier.new(a[:type], a[:id])
      end
      org[:subdivision] = Relaton.array(org[:subdivision]).map do |sd|
        LocalizedString.new sd
      end
      org[:contact] = contacts_hash_to_bib(org)
      org[:logo] = Image.new(**org[:logo][:image]) if org[:logo]
      org
    end

    def person_hash_to_bib(person)
      Person.new(
        name: fullname_hash_to_bib(person),
        credential: Relaton.array(person[:credential]),
        affiliation: affiliation_hash_to_bib(person),
        contact: contacts_hash_to_bib(person),
        identifier: person_identifiers_hash_to_bib(person),
      )
    end

    def fullname_hash_to_bib(person) # rubocop:disable Metrics/AbcSize
      n = person[:name]
      fname, inits = given_hash_to_bib n[:given] || n # `n` is for backward compatibility
      FullName.new(
        abbreviation: localizedstring(n[:abbreviation]),
        forename: fname, initials: inits,
        addition: Relaton.array(n[:addition])&.map { |f| localizedstring(f) },
        prefix: Relaton.array(n[:prefix])&.map { |f| localizedstring(f) },
        surname: localizedstring(n[:surname]),
        completename: localizedstring(n[:completename])
      )
    end

    def given_hash_to_bib(given)
      return [[], nil] unless given

      fname = Relaton.array(given[:forename])&.map { |f| forename_hash_to_bib(f) }
      inits = localizedstring(given[:formatted_initials])
      [fname, inits]
    end

    def forename_hash_to_bib(fname)
      case fname
      when Hash then Forename.new(**fname)
      when String then Forename.new(content: fname)
      end
    end

    def person_identifiers_hash_to_bib(person)
      Relaton.array(person[:identifier])&.map do |a|
        PersonIdentifier.new(a[:type], a[:id])
      end
    end

    def affiliation_hash_to_bib(person) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return [] unless person[:affiliation]

      Relaton.array(person[:affiliation]).map do |a|
        a[:description] = Relaton.array(a[:description]).map do |d|
          cnt = if d.is_a?(Hash)
                  { content: d[:content], language: d[:language],
                    script: d[:script], format: d[:format] }
                else { content: d }
                end
          FormattedString.new(**cnt)
        end
        Affiliation.new(
          organization: Organization.new(**org_hash_to_bib(a[:organization])),
          description: a[:description], name: localizedstring(a[:name])
        )
      end
    end

    def contacts_hash_to_bib(entity) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
      return [] unless entity[:contact]

      Relaton.array(entity[:contact]).map do |a|
        type, value = a.reject { |k, _| k == :type }.flatten
        case type
        when :street, :city, :state, :country, :postcode # it's for old version compatibility, should be removed in the future
          a[:street] = Relaton.array(a[:street])
          Address.new(**a)
        when :address then create_address(a[:address])
        when :phone, :email, :uri
          Contact.new(type: type.to_s, value: value, subtype: a[:type])
        else # it's for old version compatibility, should be removed in the future
          Contact.new(**a)
        end
      end
    end

    def create_address(adr)
      if adr.is_a?(Hash)
        adr[:street] = Relaton.array(adr[:street])
        Address.new(**adr)
      else
        Address.new(formatted_address: adr)
      end
    end

    # @param ret [Hash]
    def copyright_hash_to_bib(ret)
      return unless ret[:copyright]

      ret[:copyright] = Relaton.array(ret[:copyright]).map do |c|
        c[:owner] = Relaton.array(c[:owner]).map do |o|
          org_hash_to_bib(o)
        end
        c
      end
    end

    # @param ret [Hash]
    def relations_hash_to_bib(ret)
      return unless ret[:relation]

      ret[:relation] = Relaton.array(ret[:relation])
      ret[:relation]&.each do |r|
        if r[:description]
          r[:description] = FormattedString.new(**r[:description])
        end
        relation_bibitem_hash_to_bib(r)
        relation_locality_hash_to_bib(r)
        relation_source_locality_hash_to_bib(r)
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
      Item.new(**item_hash)
    end

    # @param rel [Hash] relation
    # @return [Relaton::Bib::LocalityStack]
    def relation_locality_hash_to_bib(rel)
      rel[:locality] = Relaton.array(rel[:locality])&.map do |bl|
        LocalityStack.new locality_locality_stack(bl)
      end
    end

    def locality_locality_stack(lls)
      if lls[:locality_stack]
        Relaton.array(lls[:locality_stack]).map do |lc|
          l = lc[:locality] || lc
          Locality.new(l[:type], l[:reference_from], l[:reference_to])
        end
      else
        [Locality.new(lls[:type], lls[:reference_from], lls[:reference_to])]
      end
    end

    # @param rel [Hash] relation
    def relation_source_locality_hash_to_bib(rel) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      rel[:source_locality] = Relaton.array(rel[:source_locality])&.map do |sl|
        sls = if sl[:source_locality_stack]
                Relaton.array(sl[:source_locality_stack]).map do |l|
                  SourceLocality.new(l[:type], l[:reference_from],
                                     l[:reference_to])
                end
              else
                l = SourceLocality.new(sl[:type], sl[:reference_from],
                                       sl[:reference_to])
                [l]
              end
        SourceLocalityStack.new sls
      end
    end

    # @param ret [Hash]
    def series_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      ret[:series] = Relaton.array(ret[:series])&.map do |s|
        s[:formattedref] && s[:formattedref] = formattedref(s[:formattedref])
        if s[:title]
          s[:title] = { content: s[:title] } unless s[:title].is_a?(Hash)
          s[:title] = typed_title_strig(s[:title])
        end
        s[:abbreviation] &&
          s[:abbreviation] = localizedstring(s[:abbreviation])
        Series.new(**s)
      end
    end

    # @param title [Hash]
    # @return [Relaton::Bib::TypedTitleString]
    def typed_title_strig(title)
      TypedTitleString.new(**title)
    end

    # @param ret [Hash]
    def medium_hash_to_bib(ret)
      ret[:medium] = Medium.new(**ret[:medium]) if ret[:medium]
    end

    # @param ret [Hash]
    def classification_hash_to_bib(ret)
      if ret[:classification]
        ret[:classification] = Relaton.array(ret[:classification]).map do |cls|
          Classification.new(**cls)
        end
      end
    end

    # @param ret [Hash]
    def validity_hash_to_bib(ret)
      return unless ret[:validity]

      b = parse_validity_time(ret[:validity], :begins)
      e = parse_validity_time(ret[:validity], :ends)
      r = parse_validity_time(ret[:validity], :revision)
      ret[:validity] = Validity.new(begins: b, ends: e, revision: r)
    end

    def parse_validity_time(val, period)
      t = val[period]&.to_s
      return unless t

      p = period == :ends ? -1 : 1
      case t
      when /^\d{4}$/
        Date.new(t.to_i, p, p).to_time
      when /^(?<year>\d{4})-(?<month>\d{1,2})$/
        Date.new($~[:year].to_i, $~[:month].to_i, p).to_time
      else Time.parse t
      end
    end

    # @param ret [Hash]
    def editorialgroup_hash_to_bib(ret)
      return unless ret[:editorialgroup]

      technical_committee = Relaton.array(ret[:editorialgroup]).map do |wg|
        TechnicalCommittee.new WorkGroup.new(**wg)
      end
      ret[:editorialgroup] = EditorialGroup.new technical_committee
    end

    # @param ret [Hash]
    def ics_hash_to_bib(ret)
      return unless ret[:ics]

      ret[:ics] = Relaton.array(ret[:ics]).map { |ics| ICS.new(**ics) }
    end

    # @param ret [Hash]
    def structuredidentifier_hash_to_bib(ret)
      return unless ret[:structuredidentifier]

      sids = Relaton.array(ret[:structuredidentifier]).map do |si|
        si[:agency] = Relaton.array si[:agency]
        StructuredIdentifier.new(**si)
      end
      ret[:structuredidentifier] = StructuredIdentifierCollection.new sids
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
        LocalizedString.new(lst[:content], lst[:language], lst[:script])
      else LocalizedString.new(lst)
      end
    end

    # @param frf [Hash, String]
    # @return [Relaton::Bib::FormattedRef]
    def formattedref(frf)
      if frf.is_a?(Hash)
        Relaton::Bib::FormattedRef.new(**frf)
      else
        Relaton::Bib::FormattedRef.new(content: frf)
      end
    end

    def doctype_hash_to_bib(ret)
      return unless ret[:doctype]

      ret[:doctype] = if ret[:doctype].is_a?(String)
                        create_doctype(type: ret[:doctype])
                      else create_doctype(**ret[:doctype])
                      end
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end
