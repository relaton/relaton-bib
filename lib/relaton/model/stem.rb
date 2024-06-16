module Relaton
  module Model
    class Stem < Shale::Mapper
      attribute :type, Shale::Type::String
      attribute :content, AnyElement

      xml do
        root "stem"
        map_attribute "type", to: :type
        map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
      end

      def content_from_xml(model, node)
        model.content = AnyElement.of_xml node.instance_variable_get(:@node) || node
      end

      def content_to_xml(model, parent, _doc)
        model.content.to_xml parent
      end

      def add_to_xml(parent)
        parent << to_xml
      end
    end
  end
end
