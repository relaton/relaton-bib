require_relative "bibitem_shared"

module Relaton
  module Bib
    # Bibliographic item serialized as <bibitem>. Has id, no ext.
    class Bibitem < Item
      model ItemData
      include BibitemShared
    end
  end
end
