require_relative "bib_item_locality"

module Relaton
  module Model
    class Locality < Lutaml::Model::Serializable
      include BibItemLocality

      model Bib::Locality

      mappings[:xml].instance_eval do
        root "locality"
      end
    end
  end
end
