module Relaton
  module Model
    class Sup < Lutaml::Model::Serializable
      include PureTextElement::Mapper

      mappings[:xml].instance_eval do
        root "sup"
      end
    end
  end
end
