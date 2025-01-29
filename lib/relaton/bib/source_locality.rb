module Relaton
  module Bib
    class SourceLocality < Lutaml::Model::Serializable
      include BibItemLocality

      xml do
        root "sourceLocality"
      end
    end
  end
end
