module Relaton
  module Model
    module LocalizedString
      def self.included(base)
        base.instance_eval do
          include Model::LocalizedStringAttrs

          attribute :content, Lutaml::Model::Type::String

          mappings[:xml].instance_eval do
            map_content to: :content, with: { from: :content_from_xml }
          end
        end
      end

      def content_from_xml(model, value)
        model.content = value.strip
      end
    end
  end
end
