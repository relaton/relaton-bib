module Relaton
  module Bib
    # Module to remove id, schema-version, fetched & ext attributes from Item subclasses.
    # Used for bibitem/relation instances that don't need these attributes.
    module ItemBaseAttributes
      def self.included(base)
        # we don't need id, schema-version & fetched attributes in relation/bibitem
        base.mappings[:xml].instance_variable_get(:@attributes).delete("id")
        base.mappings[:xml].instance_variable_get(:@attributes).delete("schema-version")
        base.mappings[:xml].instance_variable_get(:@elements).delete("fetched")
        base.mappings[:xml].instance_variable_get(:@elements).delete("ext")
        base.attributes.delete :id
        base.attributes.delete :schema_version
        base.attributes.delete :fetched
        base.attributes.delete :ext
      end
    end

    # The class is for relaton bibitem instances.
    # The in relaton bibitem instances dosn't have schema-version & fetched attributes.
    class ItemBase < Item
      model ItemData

      include ItemBaseAttributes
    end
  end
end
