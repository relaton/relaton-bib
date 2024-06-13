module RelatonBib
  module Element
    class Br
      include ToString

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.br
      end
    end
  end
end
