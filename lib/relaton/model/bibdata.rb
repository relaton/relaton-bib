module Relaton
  module Model
    class Bibdata < BibliographicItem
      model Relaton::Bib::Item

      mappings[:xml].instance_eval do
        root "bibdata"
      end
    end
  end
end
