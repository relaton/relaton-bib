module Relaton
  module Bib
    # This class represents a bibliographic item as a bibitem.
    class Bibitem < Item
      model ItemData

      mappings[:xml].instance_variable_get(:@elements).delete("ext")

      xml do
        root "bibitem"
      end
    end
  end
end
