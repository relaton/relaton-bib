module Relaton
  module Bib
    # Bibliographic item serialized as <bibdata>. Has ext, no id.
    class Bibdata < Lutaml::Model::Serializable
      include NamespaceHelper

      attr_accessor :type

      model ItemData

      attribute :schema_version, :string, method: :get_schema_version
      attribute :fetched, :date
      instance_exec(&ItemShared::ATTRIBUTES)
      attribute :ext, Ext

      xml do
        root "bibdata"
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
