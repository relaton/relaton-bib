require_relative "source_locality"
require_relative "source_locality_stack"

module Relaton
  module Model
    class Relation < Lutaml::Model::Serializable
      model Bib::Relation

      attribute :type, :string
      attribute :decription, LocalizedString
      attribute :bibitem, Bibitem
      attribute :locality, Locality, collection: true
      attribute :locality_stack, LocalityStack, collection: true
      attribute :source_locality, SourceLocality, collection: true
      attribute :source_locality_stack, SourceLocalityStack, collection: true

      xml do
        root "relation"

        map_attribute "type", to: :type
        map_element "description", to: :description
        map_element "bibitem", to: :bibitem
        map_element "locality", to: :locality
        map_element "localityStack", to: :locality_stack
        map_element "sourceLocality", to: :source_locality
        map_element "sourceLocalityStack", to: :source_locality_stack
      end
    end
  end
end
