module Relaton
  module Model
    class Ruby < Shale::Mapper
      module Mapper
        def self.included(base)
          base.class_eval do
            attribute :value, Shale::Type::String
            attribute :script, Shale::Type::String
            attribute :lang, Shale::Type::String

            xml do
              map_attribute "value", to: :value
              map_attribute "script", to: :script
              map_attribute "lang", to: :lang
            end
          end
        end
      end

      class Pronunciation < Shale::Mapper
        include Mapper

        @xml_mapping.instance_eval do
          root "pronunciation"
        end
      end

      class Annotation < Shale::Mapper
        include Mapper

        @xml_mapping.instance_eval do
          root "annotation"
        end
      end

      attribute :pronunciation, Pronunciation
      attribute :annotation, Annotation
      attribute :content, Shale::Type::String
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
