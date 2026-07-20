# Model classes are wired via autoload (see model_autoload.rb); the lutaml
# requires and XML adapter configuration live there so they run eagerly,
# independent of which model class is referenced first.
module Relaton
  module Bib
    # Item class repesents bibliographic item metadata.
    # Used for YAML/JSON parsing and as the XML dispatch entry point.
    class Item < Lutaml::Model::Serializable
      include NamespaceHelper

      attr_accessor :type # in some cases mehod type is unavailable

      model ItemData

      def self.from_xml(xml, options = {})
        return super unless self == namespace::Item

        # lutaml-model has no built-in dispatch on root element name
        # (polymorphic_map only works on attribute discriminators), so we
        # peek at the root tag with Nokogiri and forward to the right class.
        root_name = Nokogiri::XML(xml.to_s).root&.name
        klass = root_name == "bibdata" ? namespace::Bibdata : namespace::Bibitem
        klass.from_xml(xml, options)
      end

      attribute :id, :string
      attribute :schema_version, :string, method: :get_schema_version
      attribute :fetched, PlainDate
      instance_exec(&ItemShared::ATTRIBUTES)
      attribute :ext, Ext

      xml do
        map_attribute "id", to: :id
        map_attribute "type", to: :type
        map_attribute "schema-version", to: :schema_version, render_default: true
        map_element "fetched", to: :fetched
        instance_exec(&ItemShared::XML_BODY)
        map_element "ext", to: :ext
      end

      def get_schema_version = Relaton.schema_versions["relaton-models"]
    end
  end
end
