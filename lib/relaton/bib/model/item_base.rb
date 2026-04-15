module Relaton
  module Bib
    # Bibliographic item used as a nested element inside Relation.
    # Has neither id, schema_version, fetched, nor ext.
    class ItemBase < Lutaml::Model::Serializable
      include NamespaceHelper

      attr_accessor :type

      model ItemData

      instance_exec(&ItemShared::ATTRIBUTES)

      xml do
        map_attribute "type", to: :type
        instance_exec(&ItemShared::XML_BODY)
      end
    end
  end
end
