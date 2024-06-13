module RelatonBib
  module Element
    class Bookmark
      include ToString

      # @return [String]
      attr_reader :id

      #
      # Initialize bookmark
      #
      # @param [String] id ID of the bookmark
      #
      def initialize(id)
        @id = id
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.bookmark id: id
      end
    end
  end
end
