module RelatonBib
  module Element
    class Li
      include Base

      # @return [String, nil]
      attr_reader :id

      # @return [Array<RelatonBib::Element::ParagraphWithFootnote>]
      attr_reader :content

      #
      # Initialize a new list item element.
      #
      # @param [String, nil] id
      # @param [Array<RelatonBib::Element::ParagraphWithFootnote>] content
      #
      def initialize(content:, id: nil)
        super content: content
        @id = id
      end

      def to_xml(builder)
        node = builder.li { |b| super b }
        node["id"] = id if id
      end
    end
  end
end
