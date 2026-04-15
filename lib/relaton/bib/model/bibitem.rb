module Relaton
  module Bib
    # Bibliographic item serialized as <bibitem>. Has id, no ext.
    class Bibitem < Lutaml::Model::Serializable
      include NamespaceHelper

      attr_accessor :type

      model ItemData

      attribute :id, :string
      attribute :schema_version, :string, method: :get_schema_version
      attribute :fetched, :date
      instance_exec(&ItemShared::ATTRIBUTES)

      xml do
        root "bibitem"
        map_attribute "id", to: :id
        map_attribute "type", to: :type
        map_attribute "schema-version", to: :schema_version
        map_element "fetched", to: :fetched
        instance_exec(&ItemShared::XML_BODY)
      end

      def get_schema_version = Relaton.schema_versions["relaton-models"]
    end
  end
end
