module RelatonBib
  module Element
    module ParagraphType
      include Alignments
      include Base
      include ToString

      # @return [String]
      attr_reader :id

      # @return [String, nil] alignment left, right, center, or justify
      attr_reader :align

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      #
      # Initialize paragraph
      #
      # @param [Array<RelatonBib::Element::Text, RelatonBib::Element::Base>] content TextElement
      # @param [String] id ID
      # @param [String, nil] align left, right, center, or justify
      # @param [Array<RelatonBib::Element::Note>] note
      #
      def initialize(content, id, align: nil, note: [])
        check_alignment align
        super content: content
        @id = id
        @align = align
        @note = note
      end

      def to_xml(builder)
        builder.parent[:id] = id
        builder.parent[:align] = align if align
        super builder
        note.each { |n| n.to_xml builder }
      end
    end

    class Paragraph
      include ParagraphType

      def to_xml(builder)
        builder.p { |b| super b }
      end
    end
  end
end
