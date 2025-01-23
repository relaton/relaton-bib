module Relaton
  module Model
    class SourceLocality < Lutaml::Model::Serializable
      model Bib::SourceLocality

      include BibItemLocality

      xml do
        root "sourceLocality"
      end
    end
  end
end
