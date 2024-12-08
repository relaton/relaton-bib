module Relaton
  module Model
    class FullName < Lutaml::Model::Serializable
      include Relaton::Model::FullNameType

      model Bib::FullName

      mappings[:xml].instance_eval do
        root "name"
      end
    end
  end
end
