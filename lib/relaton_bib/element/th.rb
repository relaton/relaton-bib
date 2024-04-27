module RelatonBib
  module Element
    class Th
      include Alignments
      include Valignments
      include Base

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Text, RelatonBib::Element::Base, RelatonBib::Element::ParagraphWithFootnote>]

      def initialize(content:, **args)
        check_alignment args[:align]
        check_valignment args[:valign]
        super content
        @colspan = args[:colspan]
        @rowspan = args[:rowspan]
        @align = args[:align]
        @valign = args[:valign]
      end

      def to_xml(builder)
        node = builder.th { |b| super b }
        node["colspan"] = @colspan if @colspan
        node["rowspan"] = @rowspan if @rowspan
        node["align"] = @align if @align
        node["valign"] = @valign if @valign
      end
    end
  end
end
