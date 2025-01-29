require_relative "item"

module Relaton
  module Bib
    class Bibitem < Item
      mappings[:xml].instance_eval do
        root "bibitem"
      end

      # xml do
      #   root "bibitem"
      #   map_attribute "id", to: :id # , with: { to: :id_to_xml }
      # end

      # def id_to_xml(value)
      #   value
      # end
    end
  end
end
