module RelatonBib
  module Element
    class Dd
      include Base

      # @!attribute [r] content
      #  @return [Array<RelatonBib::Element::ParagraphWithFootnote>]

      def to_xml(builder)
        builder.dd { |b| super b }
      end
    end
  end
end
