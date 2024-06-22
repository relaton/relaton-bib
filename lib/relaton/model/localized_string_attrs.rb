module Relaton
  module Model
    module LocalizedStringAttrs
      def self.included(base)
        base.class_eval do
          attribute :language, Shale::Type::String
          attribute :locale, Shale::Type::String
          attribute :script, Shale::Type::String

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
