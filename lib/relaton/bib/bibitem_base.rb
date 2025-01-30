module Relaton
  module Bib
    # The class is for relaton bibitem instances
    class BibitemBase < BibliographicItem
      # we don't need schema-version & fetched attributes in reation/bibitem
      mappings[:xml].instance_variable_get(:@attributes).delete("schema-version")
      mappings[:xml].instance_variable_get(:@elements).delete("fetched")

      mappings[:xml].instance_eval do
        root "bibitem"
      end
    end
  end
end
