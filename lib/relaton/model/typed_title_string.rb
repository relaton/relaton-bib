module Relaton
  module Model
    class TypedTitleString < LocalizedString

      attribute :type, :string

      def self.inherited(base)
        super
        base.class_eval do
          mappings[:xml].instance_eval do
            root "typedtitlestring"
            map_attribute "type", to: :type
          end
        end
      end
    end
  end
end
