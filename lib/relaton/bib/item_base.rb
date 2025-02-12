module Relaton
  autoload :Item, "relaton/bib/item"

  module Bib
    # The class is for relaton bibitem instances.
    # The in relaton bibitem instances dosn't have schema-version & fetched attributes.
    class ItemBase < Item
      # we don't need schema-version & fetched attributes in reation/bibitem
      mappings[:xml].instance_variable_get(:@attributes).delete("schema-version")
      mappings[:xml].instance_variable_get(:@elements).delete("fetched")
    end
  end
end
