module Relaton
  module Model
    class NestedTextElement < Lutaml::Model::Serializable
      require_relative "pure_text_element"
      attribute :content, PureTextElement

      xml do
        map_content to: :content
      end
    end
  end
end
