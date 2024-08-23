module Relaton
  module Model
    class Eref < Lutaml::Model::Serializable
      include ErefType

      mappings[:xml].instance_eval do
        root "eref"
      end
    end
  end
end
