module Relaton
  module Bib
    class Extent < Lutaml::Model::Serializable
      choice(min: 1, max: 1) do
        attribute :locality, Locality, collection: true
        attribute :locality_stack, LocalityStack, collection: true
      end

      xml do
        root "extent"
        map_element "locality", to: :locality
        map_element "localityStack", to: :locality_stack
      end
    end
  end
end
