module RelatonBib
  module Element
    #
    # Base module for many elements.
    #
    module Base
      include ToString

      # @return [Array<RelatonBib::Element::Text>]
      attr_reader :content

      # @param content [Array<RelatonBib::Element::Text, RelatonBib::Element::Em, RelatonBib::Element::ErefType>]
      def initialize(content)
        @content = content
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        content.each { |c| c.to_xml builder }
      end

      def to_s
        content.map(&:to_s).join
      end
    end
  end
end
