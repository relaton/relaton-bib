module RelatonBib
  # Documett relation
  class DocumentRelation
    include RelatonBib

    TYPES = %w[
      includes includedIn hasPart partOf merges mergedInto splits splitInto
      instanceOf hasInstance exemplarOf hasExemplar manifestationOf
      hasManifestation reproductionOf hasReproduction reprintOf hasReprint
      expressionOf hasExpression translatedFrom hasTranslation arrangementOf
      hasArrangement abridgementOf hasAbridgement annotationOf hasAnnotation
      draftOf hasDraft editionOf hasEdition updates updatedBy derivedFrom
      derives describes describedBy catalogues cataloguedBy hasSuccessor
      successorOf adaptedFrom hasAdaptation adoptedFrom adoptedAs reviewOf
      hasReview commentaryOf hasCommentary related hasComplement complementOf
      obsoletes obsoletedBy cites isCitedIn
    ].freeze

    # @return [String]
    attr_accessor :type

    # @return [RelatonBib::FormattedString, nil]
    attr_reader :description

    # @return [String]
    # attr_reader :identifier, :url

    # @return [RelatonBib::BibliographicItem]
    attr_reader :bibitem

    # @return [Array<RelatonBib::Locality, RelatonBib::LocalityStack>]
    attr_reader :locality

    # @return [Array<RelatonBib::SourceLocality,
    #   RelatonBib::SourceLocalityStack>]
    attr_reader :source_locality

    # @param type [String]
    # @param description [RelatonBib::FormattedString, nil]
    # @param bibitem [RelatonBib::BibliographicItem,
    #   RelatonIso::IsoBibliographicItem]
    # @param locality [Array<RelatonBib::Locality>]
    # @param locality_stack [Array<RelatonBib::LocalityStack>]
    # @param source_locality [Array<RelatonBib::SourceLocality,
    #   RelatonBib::SourceLocalityStack>]
    def initialize(type:, bibitem:, **args)
      type = "obsoletes" if type == "Now withdrawn"
      unless self.class::TYPES.include? type
        Util.warn "Invalid relation type: `#{type}`"
      end
      @type = type
      @description = args[:description]
      @locality = args[:locality] || args[:locality_stack] || []
      @source_locality = args[:source_locality] || args[:source_locality_stack] || []
      @bibitem = bibitem
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder, **opts)
      opts.delete :bibdata
      opts.delete :note
      builder.relation(type: type) do
        builder.description { description.to_xml builder } if description
        bibitem.to_xml(**opts.merge(builder: builder, embedded: true))
        locality.each { |l| l.to_xml builder }
        source_locality.each { |l| l.to_xml builder }
      end
    end

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize
      hash = { "type" => type, "bibitem" => bibitem.to_hash(embedded: true) }
      hash["description"] = description.to_hash if description
      locality.each_with_object(hash) do |l, obj|
        k, v = l.to_hash.first
        hash[k] ||= []
        hash[k] << v
      end
      if source_locality&.any?
        hash["source_locality"] = single_element_array(source_locality)
      end
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? prefix : prefix + "."
      out = "#{prefix}.type:: #{type}\n"
      out += description.to_asciibib "#{pref}desctiption" if description
      out += bibitem.to_asciibib "#{pref}bibitem" if bibitem
      out
    end
  end
end
