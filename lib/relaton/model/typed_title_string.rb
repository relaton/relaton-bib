module Relaton
  module Model
    module TypedTitleString
      def self.included(base)
        base.class_eval do
          include Relaton::Model::LocalizedMarketUpString

          attribute :type, Shale::Type::String

          @xml_mapping.instance_eval do
            map_attribute "type", to: :type
          end
        end
      end
    end
  end
end
