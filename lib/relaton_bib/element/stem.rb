module RelatonBib
  module Element
    class Stem
      include RelatonBib::Element::Base

      TYPES = %w[MathML AsciiMath].freeze

      # @return [String]
      attr_reader :type

      # @param content [Array<RelatonBib::Element::Base, RelatonBib::Element::Text>]
      attr_reader :content

      #
      # Initialize stem
      #
      # @param [Array<RelatonBib::Element::Base, RelatonBib::Element::Text>] content AnyElement or Text
      # @param [String] type MathML, AsciiMath
      #
      def initialize(content, type)
        Util.warn "invalid stem type: `#{type}`" unless TYPES.include? type

        super content
        @type = type
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.stem(type: type) { |b| super b }
      end
    end
  end
end
