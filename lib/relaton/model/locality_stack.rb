module Relaton
  module Model
    class LocalityStack < Lutaml::Model::Serializable
      # model Relaton::Bib::LocalityStack

      attribute :connective, Lutaml::Model::Type::String
      attribute :locality, Locality, collection: true

      xml do
        root "localityStack"
        map_attribute :connective, to: :connective
        map_element :locality, to: :locality
      end
    end
  end
end
