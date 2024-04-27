module RelatonBib
  module Element
    class Dl
      include Base

      # @return [String]
      attr_reader :id

      # @!attribute [r] content
      #  @return [Array<RelatonBib::Element::Dt, RelatonBib::Element::Dd>]

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      #
      # Initialize dl element
      #
      # @param [String] id
      # @param [Array<RelatonBib::Element::Dt, RelatonBib::Element::Dd>] content
      # @param [<Type>] note
      #
      def initialize(id:, content:, note: [])
        super content: content
        @id = id
        @note = note
      end

      def to_xml(builder)
        builder.dl(id: id) do |b|
          content.each { |c| c.to_xml b }
          note.each { |n| n.to_xml b }
        end
      end
    end
  end
end
