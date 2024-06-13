module RelatonBib
  module Element
    class Quote
      class Source < ErefType
        def to_xml(builder)
          builder.source { |b| super(b) }
        end
      end

      class Author < Text
        def to_xml(builder)
          builder.author { |b| super(b) }
        end
      end

      include ToString
      include Alignments
      include Base

      # @return [String]
      attr_reader :id

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::ParagraphWithFootnote>]

      # @retrun [Array<RelatonBib::Element::Note>]
      attr_reader :note

      # @return [String, nil]
      attr_reader :alignment

      # @return [RelatonBib::Element::Quote::Source, nil]
      attr_reader :source

      # @return [RelatonBib::Element::Quote::Author, nil]
      attr_reader :author

      #
      # Initializes the quote element.
      #
      # @param [String] id
      # @param [Array<RelatonBib::Element::ParagraphWithFootnote>] content
      # @param [Array<RelatonBib::Element::Note>] note
      # @param [String, nil] alignment
      # @param [RelatonBib::Element::Quote::Source, nil] source
      # @param [RelatonBib::Element::Quote::Author, nil] author
      #
      def initialize(id:, content:, note: [], **args)
        check_alignment args[:alignment]
        @id = id
        @content = content
        @alignment = args[:alignment]
        @source = args[:source]
        @author = args[:author]
        @note = note
      end

      def to_xml(builder) # rubocop:disable Metrics/AbcSize
        node = builder.quote(id: id) do |b|
          super b
          source&.to_xml b
          author&.to_xml b
          note.each { |n| n.to_xml b }
        end
        node[:alignment] = alignment if alignment
      end
    end
  end
end
