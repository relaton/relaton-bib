module RelatonBib
  module Element
    include ToString

    class Hr
      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.hr
      end
    end
  end
end
