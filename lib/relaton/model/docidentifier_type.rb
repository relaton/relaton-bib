module Relaton
  module Model
    class DocidentifierType < LocalizedString
      def self.inherited(subclass) # rubocop:disable Metrics/MethodLength
        super

        subclass.instance_eval do
          attribute :type, :string
          attribute :scope, :string
          attribute :primary, :boolean

          mappings[:xml].instance_eval do
            map_attribute "type", to: :type
            map_attribute "scope", to: :scope
            map_attribute "primary", to: :primary
          end
        end
      end
    end
  end
end
