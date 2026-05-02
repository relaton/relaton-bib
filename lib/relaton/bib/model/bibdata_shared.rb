require_relative "item_shared"

module Relaton
  module Bib
    module BibdataShared
      def self.included(base)
        base.xml { root "bibdata" }
        ItemShared.prune_attribute(base, :id, "id")
      end
    end
  end
end
