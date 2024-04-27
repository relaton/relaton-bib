module RelatonBib
  module Element
    class Td < RelatonBib::Element::Th

      def to_xml(builder)
        builder.td { |b| super b }
      end
    end
  end
end
