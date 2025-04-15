require_relative "scii_content"

module Relaton
  module Bib
    module BibXML
      class Postal < Lutaml::Model::Serialize
        choice(min: 0, max: 1) do
          choice(min:0, max: 1) do
            attribute :city, AsciiContent
            attribute :code, AsciiContent
            attribute :country, AsciiContent
            attribute :region, AsciiContent
            attribute :street, AsciiContent
          end

          attribute :postalline, AsciiContent
        end

        xml do
          map_element "city", to: :city
          map_element "code", to: :code
          map_element "country", to: :country
          map_element "region", to: :region
          map_element "street", to: :street
          map_element "postalLine", to: :postalline
        end
      end
    end
  end
end
