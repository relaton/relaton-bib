module Relaton
  module Bib
    class Formattedref
      # @return [String]
      attr_reader :content

      def initialize(content: nil)
        @content = content
      end

      def content=(content)
        @content = content.is_a?(String) ? content : content.to_xml
      end

      # @param content [Relaton::M
      # def content=(content)
      #   @content = content.is_a?(String) ? Model::TextElement.from_xml(content) : content
      # end

      # @param [Nokogiri::XML::Builder]
      # def to_xml(builder)
      #   builder.formattedref { super }
      # end

      # @param prefix [String]
      # @return [String]
      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "formattedref" : "#{prefix}.formattedref"
        super pref
      end
    end
  end
end
