module RelatonBib
  module HashConverter
    include Factory
    extend self

    # @param args [Hash]
    # @return [Hash]
    def hash_to_bib(args) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
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
      # ret[:keyword] = RelatonBib.array(ret[:keyword])
      ret[:license] = RelatonBib.array(ret[:license])
      editorialgroup_hash_to_bib ret
      ics_hash_to_bib ret
      structuredidentifier_hash_to_bib ret
      doctype_hash_to_bib ret
      ret
    end

    def keyword_hash_to_bib(ret)
      ret[:keyword] = RelatonBib.array(ret[:keyword]).map do |keyword|
        localizedstring keyword
      end
    end

    def extent_hash_to_bib(ret)
      return unless ret[:extent]

      ret[:extent] = RelatonBib.array(ret[:extent]).map do |e|
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

      ret[:size] = RelatonBib.array(ret[:size])
      size = ret[:size]&.map do |val|
        BibliographicSize::Value.new(**val)
      end
      ret[:size] = BibliographicSize.new(size)
    end

    def title_hash_to_bib(ret)
      return unless ret[:title]

      ret[:title] = RelatonBib.array(ret[:title])
        .reduce(TypedTitleStringCollection.new) do |m, t|
        if t.is_a?(Hash) then m << TypedTitleString.new(**t)
        else
          m + TypedTitleString.from_string(t)
        end
      end
    end

    def language_hash_to_bib(ret)
      return unless ret[:language]

      ret[:language] = RelatonBib.array(ret[:language])
    end

    def script_hash_to_bib(ret)
      return unless ret[:script]

      ret[:script] = RelatonBib.array(ret[:script])
    end

    def abstract_hash_to_bib(ret)
      return unless ret[:abstract]

      ret[:abstract] = RelatonBib.array(ret[:abstract]).map do |a|
        Abstract.new(**a)
      end
    end

    def link_hash_to_bib(ret)
      return unless ret[:link]

      ret[:link] = RelatonBib.array(ret[:link])
    end

    def place_hash_to_bib(ret)
      return unless ret[:place]

      ret[:place] = RelatonBib.array(ret[:place]).map do |pl|
        pl.is_a?(String) ? Place.new(name: pl) : Place.new(**pl)
      end
    end

    def accesslocation_hash_to_bib(ret)
      return unless ret[:accesslocation]

      ret[:accesslocation] = RelatonBib.array(ret[:accesslocation])
    end

    def dates_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize
      return unless ret[:date]

      ret[:date] = RelatonBib.array(ret[:date])
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

      ret[:docid] = RelatonBib.array(ret[:docid]).map do |id|
        id[:type] ||= id[:id].match(/^\w+(?=\s)/)&.to_s
        create_docid(**id)
      end
    end

    def version_hash_to_bib(ret)
      return unless ret[:version]

      ret[:version] = RelatonBib.array(ret[:version]).map do |v|
        BibliographicItem::Version.new(v[:revision_date], v[:draft])
      end
    end

    def biblionote_hash_to_bib(ret) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      return unless ret[:biblionote]

      ret[:biblionote] = RelatonBib.array(ret[:biblionote])
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
    # @return [RelatonBib::DocumentStatus::Stage]
    def stage(stg)
      return unless stg

      args = stg.is_a?(String) ? { value: stg } : stg
      DocumentStatus::Stage.new(**args)
    end

    def contributors_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,Metrics/PerceivedComplexity
      return unless ret[:contributor]

      ret[:contributor] = RelatonBib.array(ret[:contributor])
      ret[:contributor]&.each_with_index do |c, i|
        roles = RelatonBib.array(ret[:contributor][i][:role]).map do |r|
          create_contibutor_role(r)
        end
        ret[:contributor][i][:role] = roles
        entity = person_hash_to_bib(c[:person]) || org_hash_to_bib(c[:organization])
        ret[:contributor][i][:entity] = entity
        ret[:contributor][i].delete(:person)
        ret[:contributor][i].delete(:organization)
      end
    end

    def create_contibutor_role(role)
      if role.is_a? Hash
        description = RelatonBib.array(role[:description]).map do |d|
          desc = d.is_a?(String) ? { content: d } : d
          Contributor::Role::Description.new(**desc)
        end
        { type: role[:type], description: description }
      else { type: role }
      end
    end

    def org_hash_to_bib(org) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return nil if org.nil?

      org[:identifier] = RelatonBib.array(org[:identifier])&.map do |a|
        OrgIdentifier.new(a[:type], a[:id])
      end
      org[:subdivision] = RelatonBib.array(org[:subdivision]).map do |sd|
        sd[:organization] = OrganizationType.new(**org_hash_to_bib(sd[:organization]))
        Subdivision.new(**sd)
      end
      org[:contact] = contacts_hash_to_bib(org)
      org[:logo] = Element::Image.new(**org[:logo][:image]) if org[:logo]
      org
    end

    def person_hash_to_bib(person)
      return if person.nil?

      Person.new(
        name: fullname_hash_to_bib(person),
        credential: RelatonBib.array(person[:credential]),
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
        addition: RelatonBib.array(n[:addition])&.map { |f| localizedstring(f) },
        prefix: RelatonBib.array(n[:prefix])&.map { |f| localizedstring(f) },
        surname: localizedstring(n[:surname]),
        completename: localizedstring(n[:completename])
      )
    end

    def given_hash_to_bib(given)
      return [[], nil] unless given

      fname = RelatonBib.array(given[:forename])&.map { |f| forename_hash_to_bib(f) }
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
      RelatonBib.array(person[:identifier])&.map do |a|
        PersonIdentifier.new(a[:type], a[:id])
      end
    end

    def affiliation_hash_to_bib(person) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return [] unless person[:affiliation]

      RelatonBib.array(person[:affiliation]).map do |a|
        description = RelatonBib.array(a[:description]).map do |d|
          cnt = d.is_a?(Hash) ? d : { content: d }
          Affiliation::Description.new(**cnt)
        end
        Affiliation.new(
          organization: Organization.new(**org_hash_to_bib(a[:organization])),
          description: description, name: localizedstring(a[:name])
        )
      end
    end

    def contacts_hash_to_bib(entity) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
      return [] unless entity[:contact]

      RelatonBib.array(entity[:contact]).map do |a|
        type, value = a.reject { |k, _| k == :type }.flatten
        case type
        when :street, :city, :state, :country, :postcode # it's for old version compatibility, should be removed in the future
          a[:street] = RelatonBib.array(a[:street])
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
        adr[:street] = RelatonBib.array(adr[:street])
        Address.new(**adr)
      else
        Address.new(formatted_address: adr)
      end
    end

    # @param ret [Hash]
    def copyright_hash_to_bib(ret)
      return unless ret[:copyright]

      ret[:copyright] = RelatonBib.array(ret[:copyright]).map do |c|
        owner = owners_hash_to_bib(c[:owner])
        CopyrightAssociation.new(owner: owner, from: c[:from], to: c[:to], scope: c[:scope])
      end
    end

    def owners_hash_to_bib(owners)
      RelatonBib.array(owners).map do |o|
        if o[:person]
          person_hash_to_bib(o[:person])
        elsif o[:organization]
          Organization.new(**org_hash_to_bib(o[:organization]))
        else
          Organization.new(**org_hash_to_bib(o))
        end
      end
    end

    # @param ret [Hash]
    def relations_hash_to_bib(ret)
      return unless ret[:relation]

      ret[:relation] = RelatonBib.array(ret[:relation])
      ret[:relation]&.each do |r|
        if r[:description]
          r[:description] = DocumentRelation::Description.new(**r[:description])
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
        Util.warn "WARNING: bibitem missing: `#{rel}`"
        rel[:bibitem] = nil
      end
    end

    # @param item_hash [Hash]
    # @return [RelatonBib::BibliographicItem]
    def bib_item(item_hash)
      BibliographicItem.new(**item_hash)
    end

    # @param rel [Hash] relation
    # @return [RelatonBib::LocalityStack]
    def relation_locality_hash_to_bib(rel)
      rel[:locality] = RelatonBib.array(rel[:locality])&.map do |bl|
        LocalityStack.new locality_locality_stack(bl)
      end
    end

    def locality_locality_stack(lls)
      if lls[:locality_stack]
        RelatonBib.array(lls[:locality_stack]).map do |lc|
          l = lc[:locality] || lc
          Locality.new(l[:type], l[:reference_from], l[:reference_to])
        end
      else
        [Locality.new(lls[:type], lls[:reference_from], lls[:reference_to])]
      end
    end

    # @param rel [Hash] relation
    def relation_source_locality_hash_to_bib(rel) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      rel[:source_locality] = RelatonBib.array(rel[:source_locality])&.map do |sl|
        sls = if sl[:source_locality_stack]
                RelatonBib.array(sl[:source_locality_stack]).map do |l|
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
      ret[:series] = RelatonBib.array(ret[:series])&.map do |s|
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
    # @return [RelatonBib::TypedTitleString]
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
        ret[:classification] = RelatonBib.array(ret[:classification]).map do |cls|
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

      technical_committee = RelatonBib.array(ret[:editorialgroup]).map do |wg|
        TechnicalCommittee.new WorkGroup.new(**wg)
      end
      ret[:editorialgroup] = EditorialGroup.new technical_committee
    end

    # @param ret [Hash]
    def ics_hash_to_bib(ret)
      return unless ret[:ics]

      ret[:ics] = RelatonBib.array(ret[:ics]).map { |ics| ICS.new(**ics) }
    end

    # @param ret [Hash]
    def structuredidentifier_hash_to_bib(ret)
      return unless ret[:structuredidentifier]

      sids = RelatonBib.array(ret[:structuredidentifier]).map do |si|
        si[:agency] = RelatonBib.array si[:agency]
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

    # @param lst [Hash, Array<RelatonBib::LocalizedString>, String]
    # @return [RelatonBib::LocalizedString]
    def localizedstring(lst)
      return unless lst

      if lst.is_a?(Hash)
        LocalizedString.new(lst[:content], lst[:language], lst[:script])
      else LocalizedString.new(lst)
      end
    end

    # @param frf [Hash, String]
    # @return [RelatonBib::FormattedRef]
    def formattedref(frf)
      if frf.is_a?(Hash)
        FormattedRef.new(frf[:content])
      else
        FormattedRef.new(frf)
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
