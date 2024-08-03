module Relaton
  module Model
    module LocalizedStringAttrs
      def self.included(base)
        base.class_eval do
          attribute :language, Lutaml::Model::Type::String
          attribute :locale, Lutaml::Model::Type::String
          attribute :script, Lutaml::Model::Type::String

          xml do
            map_attribute "language", to: :language
            map_attribute "locale", to: :locale
            map_attribute "script", to: :script
          end
        end
      end
    end
  end
end
