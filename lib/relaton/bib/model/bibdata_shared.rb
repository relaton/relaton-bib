module Relaton
  module Bib
    module BibdataShared
      def self.included(base)
        base.class_eval do
          xml do
            root "bibdata"
          end

          if attributes.key?(:id)
            mappings[:xml].instance_variable_get(:@attributes).delete("id")
            attributes.delete :id
          end
        end
      end
    end
  end
end
