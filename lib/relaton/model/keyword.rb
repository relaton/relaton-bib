module Relaton
  module Model
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

      model Bib::Keyword

      # attribute :content, Content
      attribute :vocab, LocalizedString, collection: true
      attribute :taxon, LocalizedString, collection: true
      attribute :vocabid, Vocabid

      xml do
        root "keyword"
        map_element "vocab", to: :vocab
        map_element "taxon", to: :taxon
        # map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
      end

      # def content_from_xml(model, node)
      #   model.content = Content.of_xml node.instance_variable_get(:@node) || node
      # end

      #
      # Convert content to XML
      #
      # @param [Relaton::Model::En] model
      # @param [Nokogiri::XML::Element] parent
      # @param [Shale::Adapter::Nokogiri::Document] doc
      #
      # def content_to_xml(model, parent, _doc)
      #   model.content.to_xml parent
      # end
    end
  end
end
