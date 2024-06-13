module RelatonBib
  module Element
    class PageBreak
      include ToString

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.pagebreak
      end
    end
  end
end
