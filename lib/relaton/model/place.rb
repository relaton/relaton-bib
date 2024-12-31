module Relaton
  module Model
    class Place < Lutaml::Model::Serializable
      class RegionType < Lutaml::Model::Serializable
        model Bib::Place::RegionType

        attribute :iso, :string
        attribute :recommended, :boolean
        attribute :content, :string

        xml do
          root "region"
          map_attribute "iso", to: :iso
          map_attribute "reccomended", to: :recommended
          map_content to: :content
        end
      end

      model Bib::Place

      attribute :city, :string
      attribute :region, RegionType, collection: true
      attribute :country, RegionType, collection: true
      attribute :formatted_place, :string
      attribute :uri, Uri

      xml do
        root "place"
        map_element "city", to: :city
        map_element "region", to: :region
        map_element "country", to: :country
        map_element "formattedPlace", to: :formatted_place
        map_element "uri", to: :uri
      end
    end
  end
end
