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

      attribute :vocab, LocalizedString
      attribute :taxon, LocalizedString, collection: true, initialize_empty: true
      attribute :vocabid, Vocabid, collection: true, initialize_empty: true

      xml do
        root "keyword"
        map_element "vocab", to: :vocab
        map_element "taxon", to: :taxon
        map_element "vocabid", to: :vocabid
      end
    end
  end
end
