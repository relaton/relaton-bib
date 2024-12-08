require_relative "bib_item_locality"

module Relaton
  module Model
    class Locality < Lutaml::Model::Serializable
      include BibItemLocality

      model Relaton::Bib::Locality

      mappings[:xml].instance_eval do
        root "locality"
      end
    end
  end
end
