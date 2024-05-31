require_relative "bibliographic_item"

module Relaton
  module Model
    class Bibitem < Shale::Mapper
      model Relaton::Bib::Item
      attribute :id, Shale::Type::String

      include BibliographicItem

      @xml_mapping.instance_eval do
        root "bibitem"
        map_attribute "id", to: :id
      end
    end
  end
end
