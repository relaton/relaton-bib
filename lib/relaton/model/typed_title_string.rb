module Relaton
  module Model
    class TypedTitleString < LocalizedString

      attribute :type, :string
      attribute :format, :string # @DEPRECATED

      def self.inherited(base)
        super
        base.class_eval do
          mappings[:xml].instance_eval do
            # root "typedtitlestring"
            map_attribute "type", to: :type
            map_attribute "format", to: :format
          end
        end
      end
    end
  end
end
