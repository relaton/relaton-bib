module Relaton
  module Model
    class SourceLocality < Lutaml::Model::Serializable
      include BibItemLocality

      xml do
        root "sourceLocality"
      end
    end
  end
end
