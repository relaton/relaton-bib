module RelatonBib
  module Element
    class Fn
      include Base
      include ToString

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Paragraph>]

      # @return [String]
      attr_reader :reference

      #
      # Initialize footnote element.
      #
      # @param [String] reference
      # @param [Array<RelatonBib::Element::Paragraph>] content
      #
      def initialize(reference:, content:)
        @reference = reference
        @content = content
      end

      def to_xml(builder)
        builder.fn(reference: reference) { |b| super b }
      end
    end
  end
end
