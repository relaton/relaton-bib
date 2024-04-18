module RelatonBib
  module Element
    #
    # Keyword node can contain PureTextElement, index, and index-xref elements.
    #
    class Keyword
      include Base
      include ToString

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.keyword { |b| super b }
      end
    end
  end
end
