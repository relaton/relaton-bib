module Relaton
  module Model
    class IndexXref < Shale::Mapper
      include IndexMapper

      attribute :also, Shale::Type::Boolean
      attribute :target, IndexMapper::Content

      @xml_mapping.instance_eval do
        root "index-xref"
        map_attribute "also", to: :also
        map_element "target", to: :target
      end
    end
  end
end