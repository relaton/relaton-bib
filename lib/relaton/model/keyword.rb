module Relaton
  module Model
    class Keyword < Lutaml::Model::Serializable
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

        def to_xml(parent)
          @elements.map do |e|
            if e.is_a? String
              parent << e
            else
              e.add_to_xml parent
            end
          end
        end
      end

      attribute :content, Content

      xml do
        root "keyword"
        map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
      end

      def content_from_xml(model, node)
        model.content = Content.of_xml node.instance_variable_get(:@node) || node
      end

      #
      # Convert content to XML
      #
      # @param [Relaton::Model::En] model
      # @param [Nokogiri::XML::Element] parent
      # @param [Shale::Adapter::Nokogiri::Document] doc
      #
      def content_to_xml(model, parent, _doc)
        model.content.to_xml parent
      end
    end
  end
end
