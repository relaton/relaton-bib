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
require_relative "item_shared"

Lutaml::Model::Config.configure do |config|
  config.xml_adapter_type = :nokogiri
end

module Relaton
  module Bib
    class Relation < Lutaml::Model::Serializable
    end

    # Item class repesents bibliographic item metadata.
    # Used for YAML/JSON parsing and as the XML dispatch entry point.
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
      attribute :schema_version, :string, method: :get_schema_version
      attribute :fetched, :date
      instance_exec(&ItemShared::ATTRIBUTES)
      attribute :ext, Ext

      xml do
        map_attribute "id", to: :id
        map_attribute "type", to: :type
        map_attribute "schema-version", to: :schema_version
        map_element "fetched", to: :fetched
        instance_exec(&ItemShared::XML_BODY)
        map_element "ext", to: :ext
      end

      def get_schema_version = Relaton.schema_versions["relaton-models"]
    end
  end
end
