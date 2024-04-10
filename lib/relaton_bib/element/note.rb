module RelatonBib
  module Element
    class Note
      include Base

      # @return [String]
      attr_reader :id

      #
      # Initialize note
      #
      # @param content [Array<RelatonBib::Element::Paragraph>]
      # @param id [String] ID
      #
      def initialize(content, id)
        super content
        @id = id
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.note(id: id) { |b| super b }
      end
    end
  end
end
