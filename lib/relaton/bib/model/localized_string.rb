module Relaton
  module Bib
    class LocalizedString < LocalizedStringAttrs
      attribute :content, :string

      xml do
        map_content to: :content
      end

      key_value do
        map "content", to: :content # , with: { from: :content_from_key_value, to: :content_to_key_value }
        map "language", to: :language
      end
    end

    class TypedLocalizedString < LocalizedString
      attribute :type, :string

      xml do
        map_attribute "type", to: :type
      end

      key_value do
        map "type", to: :type
      end
    end

    class LocalizedMarkedUpString < LocalizedStringAttrs
      attribute :content, :string

      xml do
        map_all to: :content, with: { from: :content_from_xml, to: :content_to_xml }
      end

      key_value do
        map "content", to: :content, with: { from: :content_from_key_value, to: :content_to_key_value }
        map "language", to: :language
      end

      def content_from_xml(model, value)
        model.content = value
      end

      def content_to_xml(model, parent, doc)
        doc.add_xml_fragment parent, model.content
      end

      def content_from_key_value(model, value)
        model.content = value
      end

      def content_to_key_value(model, doc)
        doc["content"] = model.content
      end
    end
  end
end
