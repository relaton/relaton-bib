module Relaton
  module Model
    class Tt < Shale::Mapper
      class Content
        def initialize(elements = [])
          @elements = elements
        end

        def self.cast(value)
          value
        end

        def self.of_xml(node)
          elms = node.children.map do |n|
            next if n.text? && n.text.strip.empty?

            case n.name
            when "eref" then Eref.of_xml n
            else PureTextElement.of_xml n
            end
          end.compact
          new elms
        end

        def to_xml(parent, doc)
          @elements.each do |element|
            element.add_to_xml parent, doc
          end
        end
      end

      attribute :content, Content

      xml do
        root "tt"
        map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
      end

      def content_from_xml(model, node)
        model.content = Content.of_xml node.instance_variable_get(:@node) || node
      end

      def content_to_xml(model, parent, doc)
        model.content.to_xml parent, doc
      end
    end
  end
end
