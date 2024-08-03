module Relaton
  module Model
    class Smallcap < Lutaml::Model::Serializable
      include Relaton::Model::PureTextElement::Mapper

      @xml_mapping.instance_eval do
        root "smallcap"
      end
    end
  end
end
