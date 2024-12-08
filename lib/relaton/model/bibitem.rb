require_relative "bibliographic_item"

module Relaton
  module Model
    class Bibitem < Lutaml::Model::Serializable
      include BibliographicItem

      model Relaton::Bib::Item

      attribute :id, :string

      mappings[:xml].instance_eval do
        root "bibitem"
        map_attribute "id", to: :id
      end

      # xml do
      #   root "bibitem"
      #   map_attribute "id", to: :id # , with: { to: :id_to_xml }
      # end

      # def id_to_xml(value)
      #   value
      # end
    end
  end
end
