module RelatonBib
  module Element
    #
    # Xref can contain PureTextElement elements.
    #
    class Xref
      include RelatonBib::Element::ReferenceFormat
      include RelatonBib::Element::Base

      # @return [String]
      attr_reader :target, :type

      # @return [String, nil]
      attr_reader :alt

      #
      # Initialize new instance of Xref
      #
      # @param [Array<RelatonBib::Element::Text, RelatonBib::Element::Base>] content PureTextElement elements
      # @param [String] target IDREF
      # @param [String] type
      # @param [String, nil] alt
      #
      def initialize(content, target, type, alt = nil)
        check_type type
        @content = content
        @target = target
        @type = type
        @alt = alt
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        node = builder.xref(target: target, type: type) { |b| super b }
        node[:alt] = alt if alt
      end
    end
  end
end
