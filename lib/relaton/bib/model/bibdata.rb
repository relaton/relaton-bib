module Relaton
  module Bib
    module BibdataShared
      def self.included(base)
        base.class_eval do
          model ItemData

          # Bibdata doesn't have id attribute.
          attributes.delete :id
          mappings[:xml].instance_variable_get(:@attributes).delete("id")

          xml do
            root "bibdata"
          end
        end
      end
    end

    # This class represents a bibliographic item as a bibdata.
    class Bibdata < Item
      include BibdataShared
    end
  end
end
