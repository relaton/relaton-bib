module Relaton
  module Model
    class Eref < Lutaml::Model::Serializable
      include ErefType

      @xml_mapping.instance_eval do
        root "eref"
      end
    end
  end
end
