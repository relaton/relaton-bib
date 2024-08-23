module Relaton
  module Model
    module LocalizedString
      class Content < Lutaml::Model::Serializable

      end

      def self.included(base)
        base.instance_eval do
          include Model::LocalizedStringAttrs

          attribute :content, Lutaml::Model::Type::String

          mappings[:xml].instance_eval do
            map_content to: :content
          end
        end
      end
    end
  end
end
