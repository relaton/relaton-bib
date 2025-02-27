module Relaton
  module Bib
    # The class is for relaton bibitem instances.
    # The in relaton bibitem instances dosn't have schema-version & fetched attributes.
    class ItemBase < Item
      model ItemData

      # we don't need id, schema-version & fetched attributes in reation/bibitem
      mappings[:xml].instance_variable_get(:@attributes).delete("id")
      mappings[:xml].instance_variable_get(:@attributes).delete("schema-version")
      mappings[:xml].instance_variable_get(:@elements).delete("fetched")
      mappings[:xml].instance_variable_get(:@elements).delete("ext")
      attributes.delete :id
      attributes.delete :schema_version
      attributes.delete :fetched
      attributes.delete :ext
    end
  end
end
