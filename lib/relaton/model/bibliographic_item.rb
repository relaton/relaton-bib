require "lutaml/model"
# require "shale/adapter/nokogiri"
require_relative "any_element"
require_relative "br"
require_relative "date"
require_relative "bib_item_locality"
require_relative "locality"
require_relative "locality_stack"
require_relative "citation_type"
require_relative "eref_type"
require_relative "eref"
require_relative "uri"
require_relative "text_element"
require_relative "pure_text_element"
require_relative "stem"
require_relative "em"
require_relative "strong"
require_relative "sub"
require_relative "sup"
require_relative "tt"
require_relative "underline"
require_relative "strike"
require_relative "smallcap"
require_relative "keyword"
require_relative "index"
require_relative "index_xref"
require_relative "xref"
require_relative "hyperlink"
require_relative "ruby"
require_relative "hr"
require_relative "pagebreak"
require_relative "bookmark"
require_relative "image"
require_relative "localized_string_attrs"
require_relative "localized_string"
require_relative "localized_marked_up_string"
require_relative "typed_title_string"
require_relative "title"
require_relative "formattedref"
require_relative "docidentifier"
require_relative "biblionote"
require_relative "full_name_type"
require_relative "fullname"
require_relative "person"
require_relative "contribution_info"
require_relative "role"
require_relative "contributor"

Shale.xml_adapter = Shale::Adapter::Nokogiri

module Relaton
  module Model
    module BibliographicItem
      def self.included(base) # rubocop:disable Metrics/MethodLength
        base.class_eval do
          attribute :type, Lutaml::Model::Type::String
          attribute :schema_version, Lutaml::Model::Type::String
          attribute :fetched, Lutaml::Model::Type::Date
          attribute :formattedref, Formattedref
          attribute :title, Bib::TitleCollection
          attribute :source, Uri, collection: true
          attribute :docidentifier, DocIdentifier, collection: true
          attribute :docnumber, Lutaml::Model::Type::String
          attribute :date, Date, collection: true

          xml do
            map_attribute "type", to: :type
            map_attribute "schema-version", to: :schema_version
            map_attribute "fetched", to: :fetched
            map_element "formattedref", to: :formattedref
            map_element "title", to: :title, using: { from: :title_from_xml, to: :title_to_xml }
            map_element "uri", to: :source
            map_element "docidentifier", to: :docidentifier
            map_element "docnumber", to: :docnumber
            map_element "date", to: :date
          end
        end
      end

      def title_from_xml(model, node)
        model.title << Title.of_xml(node)
      end

      def title_to_xml(model, parent, _doc)
        parent << model.title.to_xml
      end
    end
  end
end
