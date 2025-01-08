module Relaton
  module Bib
    # Documett relation
    class Relation
      # include Relaton

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

      # @return [Relaton::Bib::LocalizedString, nil]
      attr_accessor :description

      # @return [String]
      # attr_reader :identifier, :url

      # @return [Relaton::Bib::Item]
      attr_accessor :bibitem

      # @return [Array<Relaton::Bib::Locality>]
      attr_accessor :locality

      # @return [Array<Relaton::Bib::LocalityStack>]
      attr_accessor :locality_stack

      # @return [Array<Relaton::Bib::SourceLocality>]
      attr_accessor :source_locality

      # @return [Array<Relaton::Bib::SourceLocalityStack>]
      attr_accessor :source_locality_stack

      # @param type [String]
      # @param description [Relaton::Bib::FormattedString, nil]
      # @param bibitem [Relaton::Bib::Item, RelatonIso::IsoItem]
      # @param locality [Array<Relaton::Bib::Locality>]
      # @param locality_stack [Array<Relaton::Bib::LocalityStack>]
      # @param source_locality [Array<Relaton::Bib::SourceLocality>]
      # @param source_locality_stack [Array<Relaton::Bib::SourceLocalityStack>]
      def initialize(**args) # rubocop:disable Metrics/MethodLength
        type = args[:type] == "Now withdrawn" ? "obsoletes" : args[:type]
        unless self.class::TYPES.include? type
          Util.warn "WARNING: invalid relation type: `#{type}`"
        end
        @type = type
        @description = args[:description]
        @bibitem = args[:bibitem]
        @locality = args[:locality] || []
        @locality_stack = args[:locality_stack] || []
        @source_locality = args[:source_locality]
        @source_locality_stack = args[:source_locality_stack] || []
      end

      # # @param builder [Nokogiri::XML::Builder]
      # def to_xml(builder, **opts)
      #   opts.delete :bibdata
      #   opts.delete :note
      #   builder.relation(type: type) do
      #     builder.description { description.to_xml builder } if description
      #     bibitem.to_xml(**opts.merge(builder: builder, embedded: true))
      #     locality.each { |l| l.to_xml builder }
      #     source_locality.each { |l| l.to_xml builder }
      #   end
      # end

      # @return [Hash]
      # def to_hash # rubocop:disable Metrics/AbcSize
      #   hash = { "type" => type, "bibitem" => bibitem.to_hash(embedded: true) }
      #   hash["description"] = description.to_hash if description
      #   hash["locality"] = single_element_array(locality) if locality&.any?
      #   if source_locality&.any?
      #     hash["source_locality"] = single_element_array(source_locality)
      #   end
      #   hash
      # end

      # @param prefix [String]
      # @return [String]
      def to_asciibib(prefix = "")
        pref = prefix.empty? ? prefix : "#{prefix}."
        out = "#{prefix}.type:: #{type}\n"
        out += description.to_asciibib "#{pref}desctiption" if description
        out += bibitem.to_asciibib "#{pref}bibitem" if bibitem
        out
      end
    end
  end
end
