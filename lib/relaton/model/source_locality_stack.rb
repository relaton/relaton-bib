module Relaton
  module Model
    class SourceLocalityStack < Lutaml::Model::Serializable
      attribute :connective, :string
      attribute :source_locality, SourceLocality, collection: true

      xml do
        root "sourceLocalityStack"
        map_attribute "connective", to: :connective
        map_element "sourceLocality", to: :source_locality
      end
    end
  end
end
