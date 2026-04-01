module Relaton
  module Bib
    class Depiction < Lutaml::Model::Serializable
      attribute :scope, :string
      attribute :type, :string
      attribute :image, Image, collection: true, initialize_empty: true

      xml do
        root "depiction"
        map_attribute "scope", to: :scope
        map_attribute "type", to: :type
        map_element "image", to: :image
      end
    end
  end
end
