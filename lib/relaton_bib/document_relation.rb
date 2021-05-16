module RelatonBib
  # Documett relation
  class DocumentRelation
    include RelatonBib

    TYPES = %w[
      includes includedIn hasPart partOf merges mergedInto splits splitInto
      instance hasInstance exemplarOf hasExemplar manifestationOf
      hasManifestation reproductionOf hasReproduction reprintOf hasReprint
      expressionOf hasExpression translatedFrom hasTranslation arrangementOf
      hasArrangement abridgementOf hasAbridgement annotationOf hasAnnotation
      draftOf hasDraft editionOf hasEdition updates updatedBy derivedFrom
      derives describes describedBy catalogues cataloguedBy hasSuccessor
      successorOf adaptedFrom hasAdaptation adoptedFrom adoptedAs reviewOf
      hasReview commentaryOf hasCommentary related complements complementOf
      obsoletes obsoletedBy cites isCitedIn
    ].freeze

    # @return [String]
    attr_reader :type

    # @return [RelatonBib::FormattedString, NilClass]
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
    # @parma description [RelatonBib::FormattedString, NilClass]
    # @param bibitem [RelatonBib::BibliographicItem,
    #   RelatonIso::IsoBibliographicItem]
    # @param locality [Array<RelatonBib::Locality, RelatonBib::LocalityStack>]
    # @param source_locality [Array<RelatonBib::SourceLocality,
    #   RelatonBib::SourceLocalityStack>]
    def initialize(type:, description: nil, bibitem:, locality: [],
                   source_locality: [])
      type = "obsoletes" if type == "Now withdrawn"
      unless self.class::TYPES.include? type
        warn "[relaton-bib] WARNING: invalid relation type: #{type}"
      end
      @type = type
      @description = description
      @locality = locality
      @source_locality = source_locality
      @bibitem = bibitem
    end

    # rubocop:disable Metrics/AbcSize

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
    # rubocop:enable Metrics/AbcSize

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize
      hash = { "type" => type, "bibitem" => bibitem.to_hash }
      hash["description"] = description.to_hash if description
      hash["locality"] = single_element_array(locality) if locality&.any?
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
