module RelatonBib
  module Element
    module TableCell
      include Alignments
      include Valignments
      include Base

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Text, RelatonBib::Element::Base, RelatonBib::Element::ParagraphWithFootnote>]

      # @return [String, nil]
      attr_reader :colspan, :rowspan, :align, :valign

      def initialize(content:, **args)
        check_alignment args[:align]
        check_valignment args[:valign]
        super content: content
        @colspan = args[:colspan]
        @rowspan = args[:rowspan]
        @align = args[:align]
        @valign = args[:valign]
      end

      def to_xml(builder)
        super builder
        builder.parent["colspan"] = colspan if colspan
        builder.parent["rowspan"] = rowspan if rowspan
        builder.parent["align"] = align if align
        builder.parent["valign"] = valign if valign
      end
    end

    class Th
      include TableCell

      def to_xml(builder)
        builder.th { |b| super b }
      end
    end

    class Td
      include TableCell

      def to_xml(builder)
        builder.td { |b| super b }
      end
    end
  end
end
