module Relaton
  module Bib
    module BibitemShared
      def self.included(base)
        base.class_eval do
          xml do
            root "bibitem"
          end

          if attributes.key?(:ext)
            mappings[:xml].instance_variable_get(:@elements).delete("ext")
            attributes.delete :ext
          end
        end
      end
    end
  end
end
