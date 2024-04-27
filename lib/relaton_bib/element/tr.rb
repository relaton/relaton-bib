module RelatonBib
  module Element
    class Tr
      include Base

      # @!attribute [r] content
      #  @return [Array<RelatonBib::Element::Td, RelatonBib::Element::Th>]

      def to_xml(builder)
        builder.tr { |b| super b }
      end
    end
  end
end
