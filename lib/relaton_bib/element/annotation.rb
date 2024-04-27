module RelatonBib
  module Element
    class Annotation
      include ToString

      # @return [String]
      attr_reader :id

      # @return [RelatonBib::Element::Paragraph]
      attr_reader :content

      #
      # Initialize Annotation element.
      #
      # @param [String] id
      # @param [RelatonBib::Element::Paragraph] content
      #
      def initialize(id:, content:)
        @id = id
        @content = content
      end
    end

    def to_xml(builder)
      builder.annotation id: id do |b|
        content.to_xml b
      end
    end
  end
end
