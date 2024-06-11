module Relaton
  module Model
    class Em < Shale::Mapper
      class Content
        include Model::PureTextElement

        def initialize(elements = [])
          @elements = elements
        end

        def self.cast(value)
          value
        end

        def self.of_xml(node)
          elms = node.children.each do |n|
            case n.name
            when "text" then n.text
            when "stem" then Stem.of_xml n
            else n.to_xml
            end
          end
          new elms
        end

        def to_xml(parent, doc)
          @elements.map do |e|
            if e.is_a? String
              doc.add_text(parent, e)
            else
              doc.add_element parent, e.instance_variable_get(:@node) || e
            end
          end
        end
      end

      attribute :content, Content

      xml do
        root "em"
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
      def content_to_xml(model, parent, doc)
        model.content.to_xml parent, doc
      end
    end
  end
end
