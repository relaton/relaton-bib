require_relative "item_base"

module Relaton
  module Bib
    class Relation
      attribute :type, :string
      attribute :description, LocalizedMarkedUpString
      attribute :bibitem, ItemBase
      choice(min: 1, max: 1) do
        attribute :locality, Locality, collection: true
        attribute :locality_stack, LocalityStack, collection: true
      end
      choice(min: 1, max: 1) do
        attribute :source_locality, Locality, collection: true
        attribute :source_locality_stack, SourceLocalityStack, collection: true
      end

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
