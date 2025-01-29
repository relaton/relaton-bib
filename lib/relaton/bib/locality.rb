require_relative "bib_item_locality"

module Relaton
  module Bib
    class Locality < Lutaml::Model::Serializable
      include BibItemLocality

      mappings[:xml].instance_eval do
        root "locality"
      end
    end
  end
end
