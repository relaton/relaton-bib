module RelatonBib
  module Element
    module TextElement
      include Parser
      extend self

      ELEMENTS = %w[
        em eref strong stem sub sup tt underline keyword ruby strike smallcap xref
        br link hr pagebreak bookmark image index index-xref
      ].freeze

      #
      # Parse elements of TexElement from Sring or Nokogiri::XML::Element.
      #
      # @param [String, Nokogiri::XML::Element] content
      #
      # @return [Array<RelatonBib::Element::Base>] elements of TextElement
      #
      def parse(content) # rubocop:disable Metrics/MethodLength
        node = content_to_node(content)
        parse_children(node) { |n| parse_element n }
      end

      def parse_element(node)
        if ELEMENTS.include? node.name
          parse_node node
        else
          parse_text node
        end
      end
    end
  end
end
