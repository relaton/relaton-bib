require_relative "ext"

module Relaton
  module Bib
    class Bibdata < Item
      attribute :ext, Ext

      # we don't need id attribute in bibdata XML output
      mappings[:xml].instance_variable_get(:@attributes).delete("id")

      mappings[:xml].instance_eval do
        root "bibdata"
        map_element "ext", to: :ext
      end
    end
  end
end
