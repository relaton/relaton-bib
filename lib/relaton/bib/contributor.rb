module Relaton
  module Bib
    class Contributor < Lutaml::Model::Serializable
      class Role < Lutaml::Model::Serializable
        attribute :type, :string, values: %w[
          author performer publisher editor adapter translator distributor reazer
          owner authorizer enabler subject
        ]
        attribute :description, LocalizedMarkedUpString, collection: true

        xml do
          root "role"
          map_attribute "type", to: :type
          map_element "description", to: :description
        end
      end

      attribute :role, Role, collection: true
      # attribute :entity, ContributionInfo
      # @TODO: use `import_model ContributionInfo` for person and organization when Lutaml supports it
      choice(min: 1, max: 1) do
        attribute :person, Person
        attribute :organization, Organization
      end
      # import_model_attributes ContributionInfo

      xml do
        root "contributor"

        map_element "role", to: :role
        # map_content to: :entity, with: { from: :entity_from_xml, to: :entity_to_xml }
        map_element "person", to: :person
        map_element "organization", to: :organization # , with: { from: :organization_from_xml, to: :organization_to_xml }
      end

      # def entity
      #   person || organization
      # end

      # def entity=(value)
      #   if value.is_a? Person
      #     self.person = value
      #     self.organization = nil
      #   elsif value.is_a? Organization
      #     self.organization = value
      #     self.person = nil
      #   else
      #     raise ArgumentError, "value must be a Person or Organization"
      #   end
      # end

      # def organization_from_xml(model, node)
      #   model.entity = Organization.of_xml node
      # end

      # def organization_to_xml(model, parent, _doc)
      #   parent << model.entity.to_xml
      # end

      # def entity_from_xml(model, node)
      #   n = node.instance_variable_get(:@node) || node
      #   model.content = ContributionInfo.of_xml n
      # rescue StandardError
      # end

      # def entity_to_xml(model, parent, _doc)
      #   parent << model.content.to_xml
      # end
    end
  end
end
