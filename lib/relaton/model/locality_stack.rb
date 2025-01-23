module Relaton
  module Model
    class LocalityStack < Lutaml::Model::Serializable
      model Bib::LocalityStack

      attribute :connective, :string, values: %w[and or from to]
      attribute :locality, Locality, collection: true

      xml do
        root "localityStack"
        map_attribute "connective", to: :connective
        map_element "locality", to: :locality
      end
    end
  end
end
