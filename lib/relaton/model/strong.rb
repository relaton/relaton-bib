module Relaton
  module Model
    class Strong < Shale::Mapper
      class Content
        def initialize(elements = [])
          @elements = elements
        end

        def self.cast(value)
          value
        end

        def self.of_xml(node) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
          elms = node.children.each do |n|
            shale_node = Shale::Adapter::Nokogiri::Node.new n
            case n.name
            when "stem" then Stem.of_xml shale_node
            when "eref" then Eref.of_xml shale_node
            when "xref" then Xref.of_xml shale_node
            when "link" then Hyperlink.of_xml shale_node
            when "index" then Index.of_xml shale_node
            when "index-xref" then IndexXref.of_xml shale_node
            else PureTextElement.of_xml n
            end
          end
          new elms
        end

        def add_to_xml(parent)
          @elements.map do |e|
            parent << (e.is_a?(String) ? e : e.to_xml)
          end
        end
      end

      attribute :content, Content

      xml do
        root "strong"
        map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
      end

      def content_from_xml(model, node)
        model.content = Content.of_xml node.instance_variable_get(:@node) || node
      end

      def content_to_xml(model, parent, _doc)
        model.content.add_to_xml parent
      end
    end
  end
end
