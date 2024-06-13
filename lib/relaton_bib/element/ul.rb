module RelatonBib
  module Element
    class BaseList
      include Base

      # @!attribute [r] content
      #  @return [Array<RelatonBib::Element::Li>]

      # @return [String]
      attr_reader :id

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      #
      # Initialize ordered list element.
      #
      # @param [Array<RelatonBib::Element::Li>] content
      # @param [String] id
      # @param [Array<RelatonBib::Element::Note>] note
      #
      def initialize(content:, id:, note: [])
        super content: content
        @id = id
        @note = note
      end

      def to_xml(builder)
          builder.parent[:id] = id
          super builder
          note.each { |n| n.to_xml builder }
      end
    end

    class Ul < BaseList
      def to_xml(builder)
        builder.ul { |b| super b }
      end
    end
  end
end
