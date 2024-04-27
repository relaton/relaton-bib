module RelatonBib
  module Element
    class Thead
      # @return [RelatonBib::Element::Tr]
      attr_reader :content

      #
      # Initialize a new thead element.
      #
      # @param [RelatonBib::Element::Tr] content
      #
      def initialize(content)
        @content = content
      end

      def to_xml(builder)
        builder.thead { |b| content.to_xml b }
      end
    end
  end
end
