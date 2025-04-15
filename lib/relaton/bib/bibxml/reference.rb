require_relative "front"

module Relaton
  module Bib
    module BibXML
      class Reference < Lutaml::Model::Serialize
        attribute :anchor, String
        attribute :quote_title, String, values: %w[true false]
        attribute :target, String
        attribute :front, Front
        attribute :annotation, Annotation, collection: true
        attribute :format, Format, collection: true
        attribute :refcontent, RefContent, collection: true

        xml do
          root "reference"
          map_attribute "anchor", to: :anchor
          map_attribute "quoteTitle", to: :quote_title
          map_attribute "target", to: :target
          map_element "front", to: :front
          map_element "annotation", to: :annotation
          map_element "format", to: :format
          map_element "refcontent", to: :refcontent
        end
      end
    end
  end
end
