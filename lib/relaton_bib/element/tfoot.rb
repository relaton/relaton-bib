module RelatonBib
  module Element
    class Tfoot
      # @return [RelatonBib::Element::Tr]
      attr_reader :content

      def initialize(content)
        @content = content
      end

      def to_xml(builder)
        builder.tfoot { |b| content.to_xml b }
      end
    end
  end
end
