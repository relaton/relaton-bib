module Relaton
  module Model
    class Sub < Lutaml::Model::Serializable
      include PureTextElement::Mapper

      @xml_mapping.instance_eval do
        root "sub"
      end
    end
  end
end
