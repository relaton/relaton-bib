module RelatonBib
  module Element
    module BasicBlock
      include Parser
      extend self

      ELEMENTS = %w[
        p table formula admonition ol ul dl figure quote sourcecode example
        review pre note pagebreak hr bookmark amend
      ].freeze

      def parse(content) # rubocop:disable Metrics/MethodLength
        node = content_to_node(content)
        inline_elms = []
        block_elms = []
        parse_children(node) do |n|
          elm = parse_node(n) || parse_text(n)
          if block_element?(n.name)
            process_inline_elements(inline_elms, block_elms)
            inline_elms = []
            block_elms << elm
          else
            inline_elms << elm
          end
        end
        process_remaining_elements(inline_elms, block_elms)
        block_elms
      end

      private

      def block_element?(name)
        ELEMENTS.include?(name)
      end

      def process_inline_elements(inline_elms, block_elms)
        inline_elms.pop if inline_elms.last.is_a?(Br)
        if inline_elms.any?
          block_elms << ParagraphWithFootnote.new(content: inline_elms)
        end
      end

      def process_remaining_elements(inline_elms, block_elms)
        process_inline_elements(inline_elms, block_elms) if block_elms.any?
      end
    end
  end
end
