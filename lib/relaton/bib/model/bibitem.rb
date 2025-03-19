module Relaton
  module Bib
    module BibitemShared
      def self.included(base)
        base.class_eval do
          model ItemData

          # This class represents a bibliographic item as a bibitem.
          attributes.delete :ext
          mappings[:xml].instance_variable_get(:@elements).delete("ext")

          xml do
            root "bibitem"
          end
        end
      end
    end

    class Bibitem < Item
      include BibitemShared
    end
  end
end
