require "lutaml/model"
require "lutaml/model/xml_adapter/nokogiri_adapter"
require_relative "nested_text_element"
require_relative "em"
require_relative "strong"
require_relative "text_element"
require_relative "localized_string_attrs"
require_relative "localized_string"
require_relative "typed_localized_string"
require_relative "source"
require_relative "date"
require_relative "bib_item_locality"
require_relative "locality"
require_relative "locality_stack"
require_relative "image"
require_relative "typed_title_string"
require_relative "title"
require_relative "formattedref"
require_relative "docidentifier_type"
require_relative "docidentifier"
require_relative "biblionote"
require_relative "full_name_type"
require_relative "fullname"
require_relative "contact"
require_relative "logo"
require_relative "organization"
require_relative "affiliation"
require_relative "person"
require_relative "contribution_info"
require_relative "role"
require_relative "contributor"
require_relative "edition"
require_relative "version"
require_relative "abstract"
require_relative "status"
require_relative "copyright"
require_relative "place"
require_relative "series"
require_relative "medium"
require_relative "uri"
require_relative "price"
require_relative "extent"
require_relative "size"
require_relative "classification"
require_relative "keyword"
require_relative "validity"
require_relative "depiction"

Lutaml::Model::Config.configure do |config|
  config.xml_adapter = Lutaml::Model::XmlAdapter::NokogiriAdapter
end

module Relaton
  module Model
    autoload :Relation, "relaton/model/relation"

    class BibliographicItem < Lutaml::Model::Serializable
      def self.inherited(base) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        super

        base.class_eval do # rubocop:disable Metrics/BlockLength
          attribute :id, :string
          attribute :type, :string, values: %W[
            article book booklet manual proceedings presentation thesis techreport standard
            unpublished map electronic\sresource audiovisual film video boradcast software
            graphic_work music patent inbook incollection inproceedings journal website
            webresource dataset archival social_media alert message convesation misc
          ]
          attribute :schema_version, :string
          attribute :fetched, :date
          attribute :formattedref, :string, raw: true
          attribute :title, Title, collection: true
          attribute :source, Source, collection: true
          attribute :docidentifier, Docidentifier, collection: true
          attribute :docnumber, :string
          attribute :date, Date, collection: true
          attribute :contributor, Contributor, collection: true
          attribute :edition, Edition
          attribute :version, Version, collection: true
          attribute :note, Biblionote, collection: true
          attribute :language, :string, collection: true
          attribute :locale, :string, collection: true
          attribute :script, :string, collection: true
          attribute :abstract, Abstract, collection: true
          attribute :status, Status
          attribute :copyright, Copyright, collection: true
          attribute :relation, Relation, collection: true
          attribute :series, Series, collection: true
          attribute :medium, Medium
          attribute :place, Place, collection: true
          attribute :price, Price, collection: true
          attribute :extent, Extent, collection: true
          attribute :size, Size
          attribute :accesslocation, :string, collection: true
          attribute :license, :string, collection: true
          attribute :classification, Classification, collection: true
          attribute :keyword, Keyword, collection: true
          attribute :validity, Validity
          attribute :depiction, Depiction

          xml do # rubocop:disable Metrics/BlockLength
            map_attribute "id", to: :id
            map_attribute "type", to: :type
            map_attribute "schema-version", to: :schema_version
            map_element "fetched", to: :fetched
            map_element "formattedref", to: :formattedref
            map_element "title", to: :title # , with: { from: :title_from_xml, to: :title_to_xml }
            map_element "uri", to: :source
            map_element "docidentifier", to: :docidentifier
            map_element "docnumber", to: :docnumber
            map_element "date", to: :date
            map_element "contributor", to: :contributor
            map_element "edition", to: :edition
            map_element "version", to: :version
            map_element "note", to: :note
            map_element "language", to: :language
            map_element "locale", to: :locale
            map_element "script", to: :script
            map_element "abstract", to: :abstract
            map_element "status", to: :status
            map_element "copyright", to: :copyright
            map_element "relation", to: :relation # , with: { from: :relation_from_xml, to: :relation_to_xml }
            map_element "series", to: :series
            map_element "medium", to: :medium
            map_element "place", to: :place
            map_element "price", to: :price
            map_element "extent", to: :extent
            map_element "size", to: :size
            map_element "accesslocation", to: :accesslocation
            map_element "license", to: :license
            map_element "classification", to: :classification
            map_element "keyword", to: :keyword
            map_element "validity", to: :validity
            map_element "depiction", to: :depiction
          end

          # def title_from_xml(model, node)
          #   model.title << Title.of_xml(node)
          # end

          # def title_to_xml(model, parent, _doc)
          #   model.title.each do |title|
          #     parent << Title.to_xml(title)
          #   end
          # end

          # def relation_from_xml(model, node)
          #   model.relation << Relation.of_xml(node)
          # end

          # def relation_to_xml(model, parent, _doc)
          #   model.relation.each do |relation|
          #     parent << Relation.to_xml(relation)
          #   end
          # end
        end
      end
    end
  end
end
