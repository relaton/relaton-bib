require_relative "item_shared"

module Relaton
  module Bib
    module BibitemShared
      def self.included(base)
        base.xml { root "bibitem" }
        ItemShared.prune_attribute(base, :ext, "ext")
      end
    end
  end
end
