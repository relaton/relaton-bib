require "lutaml/model"
require "lutaml/xml"
require_relative "localized_string_attrs"
require_relative "localized_string"
require_relative "formattedref"
require_relative "abstract"
require_relative "date"
require_relative "locality"
require_relative "locality_stack"
require_relative "image"
require_relative "title"
require_relative "docidentifier"
require_relative "note"
require_relative "full_name_type"
require_relative "fullname"
require_relative "contact"
require_relative "logo"
require_relative "organization"
require_relative "affiliation"
require_relative "person"
require_relative "contribution_info"
require_relative "contributor"
require_relative "edition"
require_relative "version"
require_relative "status"
require_relative "copyright"
require_relative "place"
require_relative "series"
require_relative "medium"
require_relative "uri"
require_relative "price"
require_relative "extent"
require_relative "size"
require_relative "keyword"
require_relative "validity"
require_relative "depiction"
require_relative "source_locality_stack"
require_relative "ext"

Lutaml::Model::Config.configure do |config|
  config.xml_adapter_type = :nokogiri
end

module Relaton
  module Bib
    class Relation < Lutaml::Model::Serializable
    end

    # Item class repesents bibliographic item metadata.
    class Item < Lutaml::Model::Serializable
      include NamespaceHelper

      attr_accessor :type # in some cases mehod type is unavailable

      model ItemData

      def self.from_xml(xml, options = {})
        return super unless self == namespace::Item

        root_name = xml.to_s[/<\s*(?:[\w-]+:)?([\w-]+)/, 1]
        klass = root_name == "bibdata" ? namespace::Bibdata : namespace::Bibitem
        klass.from_xml(xml, options)
      end

      attribute :id, :string
      attribute :type, :string, values: %W[
        article book booklet manual proceedings presentation thesis techreport standard
        unpublished map electronic\sresource audiovisual film video boradcast software
        graphic_work music patent inbook incollection inproceedings journal website
        webresource dataset archival social_media alert message convesation misc
      ]
      attribute :schema_version, :string, method: :get_schema_version
      attribute :fetched, :date
      attribute :formattedref, Formattedref
      attribute :title, Title, collection: true, initialize_empty: true
      attribute :source, Uri, collection: true, initialize_empty: true
      attribute :docidentifier, Docidentifier, collection: true, initialize_empty: true
      attribute :docnumber, :string
      attribute :date, Date, collection: true, initialize_empty: true
      attribute :contributor, Contributor, collection: true, initialize_empty: true
      attribute :edition, Edition
      attribute :version, Version, collection: true, initialize_empty: true
      attribute :note, Note, collection: true, initialize_empty: true
      attribute :language, :string, collection: true, initialize_empty: true
      attribute :locale, :string, collection: true, initialize_empty: true
      attribute :script, :string, collection: true, initialize_empty: true
      attribute :abstract, Abstract, collection: true, initialize_empty: true
      attribute :status, Status
      attribute :copyright, Copyright, collection: true, initialize_empty: true
      attribute :relation, Relation, collection: true, initialize_empty: true
      attribute :series, Series, collection: true, initialize_empty: true
      attribute :medium, Medium
      attribute :place, Place, collection: true, initialize_empty: true
      attribute :price, Price, collection: true, initialize_empty: true
      attribute :extent, Extent, collection: true, initialize_empty: true
      attribute :size, Size
      attribute :accesslocation, :string, collection: true, initialize_empty: true
      attribute :license, :string, collection: true, initialize_empty: true
      attribute :classification, Docidentifier, collection: true, initialize_empty: true
      attribute :keyword, Keyword, collection: true, initialize_empty: true
      attribute :validity, Validity
      attribute :depiction, Depiction, collection: true, initialize_empty: true
      attribute :ext, Ext

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
        map_element "ext", to: :ext
      end

      def get_schema_version = Relaton.schema_versions["relaton-models"]
    end
  end
end
