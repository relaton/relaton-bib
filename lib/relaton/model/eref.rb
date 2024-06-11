module Relaton
  module Model
    class Eref < Shale::Mapper
      include ErefType

      @xml_mapping.instance_eval do
        root "eref"
      end
    end
  end
end
