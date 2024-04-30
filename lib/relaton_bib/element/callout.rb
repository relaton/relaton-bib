module RelatonBib
  module Element
    class Callout < Text
      # @return [String]
      attr_reader :target

      # @!attribute [r] content
      #  @return [RelatonBib::Element::Text]

      #
      # Initialize Callout element.
      #
      # @param [String] target IDREF
      # @param [RelatonBib::Element::Text] content
      #
      def initialize(target:, content:)
        @target = target
        super content
      end

      def to_xml(builder)
        builder.callout(target: target) { |b| super b }
      end
    end
  end
end
