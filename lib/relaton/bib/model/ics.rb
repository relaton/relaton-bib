require "isoics"

module Relaton
  module Bib
    class ICS < Lutaml::Model::Serializable
      attribute :code, :string
      attribute :text, :string

      xml do
        root "ics"
        map_element "code", to: :code
        map_element "text", to: :text
      end

      # Returns the explicit text if set, else the Isoics description for
      # `code`. Kept for consumers that read `.text` directly.
      def text
        return @text if @text.is_a?(String) && !@text.empty?

        Isoics.fetch(code)&.description if code.is_a?(String) && !code.empty?
      end

      # When code is assigned, eagerly populate text from Isoics if no
      # explicit text has been set. Going through the public writer
      # registers the value with the lutaml-model `value_set_for` tracker
      # so the attribute is emitted on serialization.
      def code=(val)
        super
        return unless val.is_a?(String) && !val.empty?
        return if @text.is_a?(String) && !@text.empty?

        description = Isoics.fetch(val)&.description
        self.text = description if description
      end

      # When the deserializer reaches the end of the XML element and
      # records that <text> was absent, it calls `using_default_for(:text)`
      # to mark the attribute as default-valued (suppressing serialization).
      # Refuse that mark if we've already populated text from Isoics so the
      # value survives round-trip. See #112.
      def using_default_for(attribute_name)
        return if attribute_name == :text &&
          @text.is_a?(String) && !@text.empty?

        super
      end
    end
  end
end
