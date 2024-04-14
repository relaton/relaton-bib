module RelatonBib
  module Element
    #
    # Hyperlink contains PureTextElement elements.
    #
    class Hyperlink
      include RelatonBib::Element::ReferenceFormat
      include RelatonBib::Element::Base

      # @return [String]
      attr_reader :target, :type

      # @return [String, nil]
      attr_reader :alt

      #
      # Initialize new instance of Hyperlink
      #
      # @param [Array<RelatonBib::Element::Text, RelatonBib::Element::Base>] content PureTextElement elements
      # @param [String] target anyURI
      # @param [String] type
      # @param [String, nil] alt
      #
      def initialize(content, target, type, alt = nil)
        check_type type
        super content
        @target = target
        @type = type
        @alt = alt
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        node = builder.link(target: target, type: type) { |b| super b }
        node[:alt] = alt if alt
      end
    end
  end
end
