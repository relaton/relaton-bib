module Relaton
  module Model
    class Smallcap < Lutaml::Model::Serializable
      include Relaton::Model::PureTextElement::Mapper

      mappings[:xml].instance_eval do
        root "smallcap"
      end
    end
  end
end
