module RelatonBib
  module Element
    class Callout < Text
      #
      # Initialize Callout element.
      #
      # @param [String] targer IDREF
      # @param [RelatonBib::Element::Text] content
      #
      def initialize(targer:, content:)
        @targer = targer
        super content
      end

      def to_xml(builder)
        builder.callout(target: @targer) { |b| super b }
      end
    end
  end
end
