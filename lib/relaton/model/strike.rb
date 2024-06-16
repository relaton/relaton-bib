module Relaton
  module Model
    class Strike < Shale::Mapper
      class Content
        def initialize(elements = [])
          @elements = elements
        end

        def self.cast(value)
          value
        end

        def self.of_xml(node)
          elms = node.children.map do |n|
            shale_node = Shale::Adapter::Nokogiri::Node.new n
            case n.name
            when "index" then Index.of_xml shale_node
            when "index-xref" then IndexXref.of_xml shale_node
            else PureTextElement.of_xml n
            end
          end.compact
          new elms
        end

        def add_to_xml(parent)
          @elements.each { |e| e.add_to_xml parent }
        end
      end

      attribute :content, Content

      xml do
        root "strike"
        map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
      end

      def content_from_xml(model, node)
        model.content = Content.of_xml(node.instance_variable_get(:@node) || node)
      end

      def content_to_xml(model, parent, _doc)
        model.content.add_to_xml parent
      end
    end
  end
end
