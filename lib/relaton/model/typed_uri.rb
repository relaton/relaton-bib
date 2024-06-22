module Relaton
  module Model
    module TypedUri
      def self.included(base) # rubocop:disable Metrics/MethodLength
        base.class_eval do
          attribute :type, Shale::Type::String
          attribute :language, Shale::Type::String
          attribute :locale, Shale::Type::String
          attribute :script, Shale::Type::String
          attribute :content, Shale::Type::String

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
