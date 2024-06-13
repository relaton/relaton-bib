module RelatonBib
  module Element
    class Tbody
      include Base

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Tr>]

      def to_xml(builder)
        builder.tbody { |b| super b }
      end
    end
  end
end
