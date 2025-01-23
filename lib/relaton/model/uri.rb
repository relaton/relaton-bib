module Relaton
  module Model
    # Contact URI
    class Uri < LocalizedStringAttrs
      model Bib::Uri

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
