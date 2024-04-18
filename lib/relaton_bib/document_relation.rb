module RelatonBib
  # Documett relation
  class DocumentRelation
    class Description
      include LocalizedStringAttrs
      include Element::Base

      def initialize(content:, **args)
        super
        @content = content.is_a?(String) ? Element.parse_text_elements(content) : content
      end

      def to_xml(builder)
        builder.description { |b| super b }
      end
    end

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

    # @return [RelatonBib::DocumentRelation::Description, nil]
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
    # @param description [RelatonBib::DocumentRelation::Description, nil]
    # @param bibitem [RelatonBib::BibliographicItem,
    #   RelatonIso::IsoBibliographicItem]
    # @param locality [Array<RelatonBib::Locality, RelatonBib::LocalityStack>]
    # @param source_locality [Array<RelatonBib::SourceLocality,
    #   RelatonBib::SourceLocalityStack>]
    def initialize(type:, bibitem:, description: nil, locality: [],
                   source_locality: [])
      type = "obsoletes" if type == "Now withdrawn"
      unless self.class::TYPES.include? type
        Util.warn "WARNING: invalid relation type: `#{type}`"
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
        description&.to_xml builder
        bibitem.to_xml(**opts.merge(builder: builder, embedded: true))
        locality.each { |l| l.to_xml builder }
        source_locality.each { |l| l.to_xml builder }
      end
    end
    # rubocop:enable Metrics/AbcSize

    # @return [Hash]
    def to_h # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      hash = { "type" => type, "bibitem" => bibitem.to_h(embedded: true) }
      hash["description"] = description.to_h if description
      hash["locality"] = locality.map(&:to_h) if locality&.any?
      hash["source_locality"] = source_locality.map(&:to_h) if source_locality&.any?
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? prefix : "#{prefix}."
      out = "#{prefix}.type:: #{type}\n"
      out += description.to_asciibib "#{pref}description" if description
      out += bibitem.to_asciibib "#{pref}bibitem" if bibitem
      out
    end
  end
end
