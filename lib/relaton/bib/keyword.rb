module Relaton
  module Bib
    class Keyword < Lutaml::Model::Serializable
      class Vocabid < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :uri, :string
        attribute :code, :string
        attribute :term, :string

        xml do
          map_attribute "type", to: :type
          map_attribute "uri", to: :uri
          map_element "code", to: :code
          map_element "term", to: :term
        end
      end

      attribute :vocab, LocalizedMarkedUpString, collection: true
      attribute :taxon, LocalizedMarkedUpString, collection: (1..)
      attribute :vocabid, Vocabid

      xml do
        root "keyword"
        map_element "vocab", to: :vocab
        map_element "taxon", to: :taxon
        map_element "vocabid", to: :vocabid
      end
    end
  end
end
