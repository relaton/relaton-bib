require_relative "eref_type"

module Relaton
  module Bib
    class Eref < Lutaml::Model::Serializable
      include ErefType

      mappings[:xml].instance_eval do
        root "eref"
      end
    end
  end
end
