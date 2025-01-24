require_relative "ext"

module Relaton
  module Model
    class Bibdata < BibliographicItem
      model Relaton::Bib::Item

      attribute :ext, Ext

      mappings[:xml].instance_eval do
        root "bibdata"
        map_element "ext", to: :ext
      end
    end
  end
end
