module RelatonBib
  module Element
    class Br
      include ToString

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.br
      end

      def to_s
        "<br/>"
      end
    end
  end
end
