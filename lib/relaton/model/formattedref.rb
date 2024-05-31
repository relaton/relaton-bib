module Relaton
  module Model
    class Formattedref < Shale::Mapper
      include TextElement

      @xml_mapping.instance_eval do
        root "formattedref"
      end
    end
  end
end
