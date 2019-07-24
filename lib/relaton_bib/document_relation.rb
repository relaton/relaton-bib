module RelatonBib
  # module DocumentRelationType
  #   PARENT        = 'parent'
  #   CHILD         = 'child'
  #   OBSOLETES     = 'obsoletes'
  #   UPDATES       = 'updates'
  #   COMPLEMENTS   = 'complements'
  #   DERIVED_FORM  = 'derivedForm'
  #   ADOPTED_FORM  = 'adoptedForm'
  #   EQUIVALENT    = 'equivalent'
  #   IDENTICAL     = 'identical'
  #   NONEQUIVALENT = 'nonequivalent'
  # end
  class << self
    def relations_hash_to_bib(ret)
      return unless ret[:relation]
      ret[:relation] = array(ret[:relation])
      ret[:relation]&.each_with_index do |r, i|
        relation_bibitem_hash_to_bib(ret, r, i)
        relation_biblocality_hash_to_bib(ret, r, i)
      end
    end

    def relation_bibitem_hash_to_bib(ret, r, i)
      if r[:bibitem] then ret[:relation][i][:bibitem] =
          BibliographicItem.new(hash_to_bib(r[:bibitem], true))
      else
        warn "bibitem missing: #{r}"
        ret[:relation][i][:bibitem] = nil
      end
    end

    def relation_biblocality_hash_to_bib(ret, r, i)
      ret[:relation][i][:bib_locality] =
        array(r[:bib_locality])&.map do |bl|
          BibItemLocality.new(bl[:type], bl[:reference_from],
                              bl[:reference_to])
        end
    end
  end

  # Documett relation
  class DocumentRelation
    # @return [String]
    attr_reader :type

    # @return [String]
    # attr_reader :identifier, :url

    # @return [RelatonBib::BibliographicItem]
    attr_reader :bibitem

    # @return [Array<RelatonBib::BibItemLocality>]
    attr_reader :bib_locality

    # @param type [String]
    # @param bibitem [RelatonBib::BibliographicItem, RelatonIso::IsoBibliographicItem]
    # @param bib_locality [Array<RelatonBib::BibItemLocality>]
    def initialize(type:, bibitem:, bib_locality: [])
      type = "obsoletes" if type == "Now withdrawn"
      @type         = type
      @bib_locality = bib_locality
      @bibitem      = bibitem
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder, **opts)
      opts.delete :bibdata
      opts.delete :note
      builder.relation(type: type) do
        bibitem.to_xml(builder, **opts.merge(embedded: true))
        bib_locality.each do |l|
          l.to_xml builder
        end
      end
    end
  end
end
