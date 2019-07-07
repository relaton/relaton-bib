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
      return unless ret[:relations]
      ret[:relations] = array(ret[:relations])
      ret[:relations]&.each_with_index do |r, i|
        ret[:relations][i][:bibitem] =
          BibliographicItem.new(hash_to_bib(ret[:relations][i][:bibitem], true))
        ret[:relations][i][:bib_locality] =
          array(ret[:relations][i][:bib_locality])&.map do |bl|
            BibItemLocality.new(bl[:type], bl[:reference_from],
                                bl[:reference_to])
          end
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
