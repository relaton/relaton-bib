module Relaton
  module Model
    class IndexXref < Lutaml::Model::Serializable
      include IndexMapper

      attribute :also, Lutaml::Model::Type::Boolean
      attribute :target, IndexMapper::Content

      mappings[:xml].instance_eval do
        root "index-xref"
        map_attribute "also", to: :also
        map_element "target", to: :target
      end
    end
  end
end
