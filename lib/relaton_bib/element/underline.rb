module RelatonBib
  module Element
    #
    # Underline can contain PureText elements.
    #
    class Underline
      include RelatonBib::Element::Base

      # @return [String] Style
      attr_reader :style

      #
      # Initialize new instance of Underline
      #
      # @param [Array<RelatonBib::Element::Base, RelatonBib::Element::Text>] content PureText elements
      # @param [String, nil] style
      #
      def initialize(content, style = nil)
        super content
        @style = style
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        node = builder.underline { |b| super b }
        node["style"] = style if style
      end
    end
  end
end
