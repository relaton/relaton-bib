module Relaton
  module Model
    class Sub < Lutaml::Model::Serializable
      include PureTextElement::Mapper

      mappings[:xml].instance_eval do
        root "sub"
      end
    end
  end
end
