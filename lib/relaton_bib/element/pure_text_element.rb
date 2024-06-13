module RelatonBib
  module Element
    module PureTextElement
      include Parser
      extend self

      ELEMENTS = %w[em strong sub sup tt underline strike smallcap br].freeze

      def parse(content)
        return [] if content.nil?

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
