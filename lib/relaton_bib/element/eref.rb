module RelatonBib
  module Element
    class Eref < RelatonBib::Element::ErefType
      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.eref { |b| super(b) }
      end
    end
  end
end
