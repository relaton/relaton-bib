module Relaton
  module Bib
    class Uri < LocalizedStringAttrs
      attribute :type, :string
      attribute :content, :string

      xml do
        map_attribute "type", to: :type
        map_content to: :content
      end

      key_value do
        map "type", to: :type
        map "content", to: :content
      end
    end
  end
end
