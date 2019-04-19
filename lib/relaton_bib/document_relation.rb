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
    def to_xml(builder)
      builder.relation(type: type) do
        bibitem.to_xml(builder)
        bib_locality.each do |l|
          l.to_xml builder
        end
      end
    end
  end
end