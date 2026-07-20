module Relaton
  module Bib
    # Bibliographic item serialized as <bibdata>. Has ext, no id.
    class Bibdata < Item
      model ItemData
      include BibdataShared
    end
  end
end
