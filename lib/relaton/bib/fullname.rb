module Relaton
  module Bib
    class FullName < Lutaml::Model::Serializable
      include FullNameType

      mappings[:xml].instance_eval do
        root "name"
      end
    end
  end
end
