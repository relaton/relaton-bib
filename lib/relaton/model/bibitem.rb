require_relative "bibliographic_item"

module Relaton
  module Model
    class Bibitem < BibliographicItem
      model Relaton::Bib::Item

      mappings[:xml].instance_eval do
        root "bibitem"
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
