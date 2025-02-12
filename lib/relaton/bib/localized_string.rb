module Relaton
  module Bib
    class LocalizedString < LocalizedStringAttrs
      attribute :content, :string

      xml do
        map_content to: :content
      end
    end

    class TypedLocalizedString < LocalizedString
      attribute :type, :string

      xml do
        map_attribute "type", to: :type
      end
    end

    class LocalizedMarkedUpString < LocalizedStringAttrs
      attribute :content, :string

      xml do
        map_all to: :content
      end
    end
  end
end
