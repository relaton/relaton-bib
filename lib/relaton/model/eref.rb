module Relaton
  module Model
    class Eref < Shale::Mapper
      include ErefType

      @xml_mapping.instance_eval do
        root "eref"
      end

      def add_to_xml(parent, _doc)
        parent << to_xml
      end
    end
  end
end
