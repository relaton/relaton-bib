module Relaton
  module Model
    class Contributor < Lutaml::Model::Serializable
      attribute :role, Role, collection: true
      attribute :content, ContributionInfo

      xml do
        root "contributor"

        map_element "role", to: :role
        map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
      end

      def content_from_xml(model, node)
        n = node.instance_variable_get :@node || node
        model.content = ContributionInfo.of_xml n
      end

      def content_to_xml(model, parent, _doc)
        parent << model.content.to_xml
      end
    end
  end
end
