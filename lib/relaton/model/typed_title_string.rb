module Relaton
  module Model
    module TypedTitleString
      def self.included(base)
        base.class_eval do
          include Relaton::Model::LocalizedMarkedUpString

          attribute :type, Lutaml::Model::Type::String

          @xml_mapping.instance_eval do
            map_attribute "type", to: :type
          end
        end
      end
    end
  end
end
