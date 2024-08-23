require_relative "bibliographic_item"

module Relaton
  module Model
    class Bibitem < Lutaml::Model::Serializable
      include BibliographicItem

      model Relaton::Bib::Item
      attribute :id, Lutaml::Model::Type::String

      mappings[:xml].instance_eval do
        root "bibitem"
        map_attribute "id", to: :id
      end
    end
  end
end
