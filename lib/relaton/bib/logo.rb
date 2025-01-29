module Relaton
  module Bib
    class Logo < Lutaml::Model::Serializable
      attribute :image, Image

      xml do
        root "logo"
        map_element "image", to: :image
      end
    end
  end
end
