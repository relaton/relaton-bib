module Relaton
  module Bib
    class Formattedref < LocalizedMarkedUpString
      attribute :format, :string

      xml do
        root "formattedref"
        map_attribute "format", to: :format
      end

      key_value do
        map "format", to: :format
      end

      # Handle plain string input from YAML/JSON deserialization
      def self.from_yaml(value)
        return new(content: value) if value.is_a?(String)

        super
      end

      def self.from_json(value)
        return new(content: value) if value.is_a?(String)

        super
      end

      # Serialize as plain string when only content is present
      def self.as(format, instance, options = {})
        return instance.content if simple_content?(instance, format)

        super
      end

      def self.simple_content?(instance, format)
        return false if format == :xml

        instance.format.nil? && instance.language.nil? &&
          instance.script.nil? && instance.locale.nil?
      end
    end
  end
end
