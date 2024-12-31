module Relaton
  module Model
    class Extent < Lutaml::Model::Serializable
      model Bib::Extent

      attribute :locality, Locality, collection: true
      attribute :locality_stack, LocalityStack, collection: true

      xml do
        root "extent"
        map_element "locality", to: :locality
        map_element "localityStack", to: :locality_stack
      end
    end
  end
end
