module Relaton
  module Bib
    # Contact URI
    class Uri < LocalizedStringAttrs
      attribute :type, :string
      attribute :content, :string

      xml do
        root "uri"
        map_attribute "type", to: :type
        map_content to: :content
      end
    end
  end
end
