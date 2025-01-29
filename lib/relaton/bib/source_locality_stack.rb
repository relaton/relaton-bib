module Relaton
  module Bib
    class SourceLocalityStack < Lutaml::Model::Serializable
      attribute :connective, :string, values: %w[and or from to]
      attribute :source_locality, SourceLocality, collection: true

      xml do
        root "sourceLocalityStack"
        map_attribute "connective", to: :connective
        map_element "sourceLocality", to: :source_locality
      end
    end
  end
end
