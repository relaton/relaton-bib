module Relaton
  module Model
    class Contributor < Lutaml::Model::Serializable
      model Bib::Contributor

      attribute :role, Role, collection: true
      # attribute :entity, ContributionInfo
      attribute :person, Person
      attribute :organization, Organization

      xml do
        root "contributor"

        map_element "role", to: :role
        # map_content with: { from: :entity_from_xml, to: :entity_to_xml }
        map_element "person", to: :person
        map_element "organization", to: :organization # , with: { from: :organization_from_xml, to: :organization_to_xml }
      end

      # def organization_from_xml(model, node)
      #   model.entity = Organization.of_xml node
      # end

      # def organization_to_xml(model, parent, _doc)
      #   parent << model.entity.to_xml
      # end

      # def entity_from_xml(model, node)
      #   n = node.instance_variable_get :@node || node
      #   model.content = ContributionInfo.of_xml n
      # end

      # def entity_to_xml(model, parent, _doc)
      #   parent << model.content.to_xml
      # end
    end
  end
end
