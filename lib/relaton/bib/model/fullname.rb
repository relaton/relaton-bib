module Relaton
  module Bib
    class FullName < Lutaml::Model::Serializable
      include FullNameType

      xml do
        root "name"
      end
    end
  end
end
