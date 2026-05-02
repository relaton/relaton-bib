module Relaton
  module Bib
    class LocalizedString < LocalizedStringAttrs
      attribute :content, :string

      xml do
        map_content to: :content
      end

      key_value do
        map "content", to: :content
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
      attribute :content, :string, raw: true

      xml do
        map_all to: :content
      end

      key_value do
        map "content", to: :content
        map "language", to: :language
      end
    end
  end
end
