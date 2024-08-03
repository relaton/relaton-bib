module Relaton
  module Model
    module TypedUri
      def self.included(base) # rubocop:disable Metrics/MethodLength
        base.class_eval do
          attribute :type, Lutaml::Model::Type::String
          attribute :language, Lutaml::Model::Type::String
          attribute :locale, Lutaml::Model::Type::String
          attribute :script, Lutaml::Model::Type::String
          attribute :content, Lutaml::Model::Type::String

          xml do
            map_attribute "type", to: :type
            map_attribute "language", to: :language
            map_attribute "locale", to: :locale
            map_attribute "script", to: :script
            map_content to: :content
          end
        end
      end
    end
  end
end
