module Relaton
  module Bib
    class Depiction < Lutaml::Model::Serializable
      attribute :scope, :string
      attribute :image, Image

      xml do
        root "depiction"
        map_attribute "scope", to: :scope
        map_element "image", to: :image
      end
    end
  end
end
