module Relaton
  module Bib
    class Formattedref < LocalizedMarkedUpString
      attribute :format, :string

      xml do
        root "formattedref"
        map_attribute "format", to: :format
      end

      key_value do
        map "content", to: :content,
                       with: { to: :content_to_kv, from: :content_from_kv }
        map "format", to: :format
      end

      def content_to_kv(model, parent)
        if self.class.simple_content?(model)
          parent.value = model.content
          parent.children.clear
        else
          parent["content"] = model.content
        end
      end

      def content_from_kv(model, value)
        model.content = value
      end

      # Handle plain string input during attribute casting
      def self.of_yaml(data, options = {})
        return new(content: data) if data.is_a?(String)

        super
      end

      def self.of_json(data, options = {})
        return new(content: data) if data.is_a?(String)

        super
      end

      def self.simple_content?(instance)
        instance.format.nil? && instance.language.nil? &&
          instance.script.nil? && instance.locale.nil?
      end
    end
  end
end
