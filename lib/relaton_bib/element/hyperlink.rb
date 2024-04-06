module RelatonBib
  module Element
    #
    # Hyperlink contains PureTextElement elements.
    #
    class Hyperlink
      include RelatonBib::Element::Base
      include RelatonBib::Element::ReferenceFormat

      # @return [Array<RelatonBib::Element::PureText>]
      attr_reader :content

      # @return [String]
      attr_reader :link, :type

      # @return [String, nil]
      attr_reader :alt

      #
      # Initialize new instance of Hyperlink
      #
      # @param [Array<RelatonBib::Element::PureText>] content
      # @param [String] link anyURI
      # @param [String] type
      # @param [String, nil] alt
      #
      def initialize(content, link:, type:, alt: nil)
        Util.warn "invalid hyperlink type: #{type}" unless TYPES.include?(type)
        super content
        @link = link
        @type = type
        @alt = alt
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        node = builder.hyperlink(link: link, type: type) { |b| super b }
        node[:alt] = alt if alt
      end
    end
  end
end
