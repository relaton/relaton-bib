module Relaton
  module Model
    class NestedTextElement < Lutaml::Model::Serializable
      require_relative "pure_text_element"
      include PureTextElement

      attribute :content, :string

      xml do
        map_all to: :content
      end
    end
  end
end
