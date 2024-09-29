module Relaton
  module Model
    class Formattedref < Lutaml::Model::Serializable

      model Bib::Formattedref

      attribute :content, TextElement # , collection: true

      xml do
        root "formattedref"
        map_content to: :text, delegate: :content # , with: { to: :content_to_xml, from: :content_from_xml }
        map_element "em", to: :em, delegate: :content # , with: { to: :em_to_xml, from: :em_from_xml }
        map_element "strong", to: :strong, delegate: :content # , with: { to: :strong_to_xml, from: :strong_from_xml }
      end

      def content_to_xml(model, parent, doc)
        parent << doc.create_element("content", model.content)
      end

      def content_from_xml(model, value)
        model.content << value
      end

      def em_from_xml(model, value)
        model.content << value.to_xml
      end

      def em_to_xml(model, parent, doc)
        parent << doc.create_element("em", model.content)
      end

      def strong_from_xml(model, value)
        model.content << value.to_xml
      end

      def strong_to_xml(model, parent, doc)
        parent << doc.create_element("strong", model.content)
      end
    end
  end
end
