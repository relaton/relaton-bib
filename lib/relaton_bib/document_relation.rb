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

  # Documett relation
  class DocumentRelation
    include RelatonBib

    # @return [String]
    attr_reader :type

    # @return [String]
    # attr_reader :identifier, :url

    # @return [RelatonBib::BibliographicItem]
    attr_reader :bibitem

    # @return [Array<RelatonBib::Locality, RelatonBib::LocalityStack>]
    attr_reader :locality

    # @return [Array<RelatonBib::SourceLocality, RelatonBib::SourceLocalityStack>]
    attr_reader :source_locality

    # @param type [String]
    # @param bibitem [RelatonBib::BibliographicItem, RelatonIso::IsoBibliographicItem]
    # @param locality [Array<RelatonBib::Locality, RelatonBib::LocalityStack>]
    # @param source_locality [Array<RelatonBib::SourceLocality, RelatonBib::SourceLocalityStack>]
    def initialize(type:, bibitem:, locality: [], source_locality: [])
      type             = "obsoletes" if type == "Now withdrawn"
      @type            = type
      @locality        = locality
      @source_locality = source_locality
      @bibitem         = bibitem
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder, **opts)
      opts.delete :bibdata
      opts.delete :note
      builder.relation(type: type) do
        bibitem.to_xml(builder, **opts.merge(embedded: true))
        locality.each { |l| l.to_xml builder }
        source_locality.each { |l| l.to_xml builder }
      end
    end

    # @return [Hash]
    def to_hash
      hash = { "type" => type, "bibitem" => bibitem.to_hash }
      hash["locality"] = single_element_array(locality) if locality&.any?
      if source_locality&.any?
        hash["source_locality"] = single_element_array(source_locality)
      end
      hash
    end
  end
end
