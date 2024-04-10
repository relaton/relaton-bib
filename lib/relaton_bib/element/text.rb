module RelatonBib
  module Element
    #
    # Text element contains text content.
    #
    class Text
      # @return [String]
      attr_reader :content

      #
      # Initialize new text element.
      #
      # @param [String] content text content
      #
      def initialize(content)
        @content = content
      end

      #
      # Add text to parent XML node.
      #
      # @param builder [Nokogiri::XML::Builder]
      #
      def to_xml(builder)
        builder.text content
      end

      #
      # @return [String]
      #
      def to_s
        content
      end
    end
  end
end
