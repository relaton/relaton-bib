module Relaton
  module Model
    class Ruby < Lutaml::Model::Serializable
      module Mapper
        def self.included(base)
          base.class_eval do
            attribute :value, Lutaml::Model::Type::String
            attribute :script, Lutaml::Model::Type::String
            attribute :lang, Lutaml::Model::Type::String

            xml do
              map_attribute "value", to: :value
              map_attribute "script", to: :script
              map_attribute "lang", to: :lang
            end
          end
        end
      end

      class Pronunciation < Lutaml::Model::Serializable
        include Mapper

        @xml_mapping.instance_eval do
          root "pronunciation"
        end
      end

      class Annotation < Lutaml::Model::Serializable
        include Mapper

        @xml_mapping.instance_eval do
          root "annotation"
        end
      end

      attribute :pronunciation, Pronunciation
      attribute :annotation, Annotation
      attribute :content, Lutaml::Model::Type::String
      attribute :ruby, Ruby

      xml do
        root "ruby"
        map_element "pronunciation", to: :pronunciation
        map_element "annotation", to: :annotation
        map_content to: :content
        map_element "ruby", to: :ruby
      end
    end
  end
end
