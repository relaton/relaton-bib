module Relaton
  module Bib
    class Address < Lutaml::Model::Serializable
      attribute :street, :string, collection: true
      attribute :city, :string
      attribute :state, :string
      attribute :country, :string
      attribute :postcode, :string
      attribute :formatted_address, :string, raw: true

      xml do
        root "address"
        map_element "street", to: :street
        map_element "city", to: :city
        map_element "state", to: :state
        map_element "country", to: :country
        map_element "postcode", to: :postcode
        map_element "formattedAddress", to: :formatted_address
      end
    end
  end
end
