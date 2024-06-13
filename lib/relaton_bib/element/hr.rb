module RelatonBib
  module Element
    class Hr
      include ToString

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.hr
      end
    end
  end
end
