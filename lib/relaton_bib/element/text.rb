module RelatonBib
  module Element
    #
    # Text element can contain text, em, eref, strong, stem, sub, sup, tt, underline,
    # keyword, ruby, strike, smallcap, xref, br, hiperlink, hr, pagebreak, bookmark,
    # image, indef, and index-xref elements.
    #
    class Text
      # @return [String]
      attr_reader :content

      def initialize(content)
        @content = content
      end

      def to_xml(builder)
        builder.text content
      end

      def to_s
        content
      end
    end
  end
end
