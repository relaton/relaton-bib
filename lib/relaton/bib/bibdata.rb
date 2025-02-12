module Relaton
  module Bib
    # This class represents a bibliographic item as a bibdata.
    class Bibdata < Item
      model ItemData

      mappings[:xml].instance_variable_get(:@attributes).delete("id")

      xml do
        root "bibdata"
      end
    end
  end
end
