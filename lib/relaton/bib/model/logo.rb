module Relaton
  module Bib
    class Logo < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :image, Image

      xml do
        root "logo"
        map_attribute "type", to: :type
        map_element "image", to: :image
      end
    end
  end
end
