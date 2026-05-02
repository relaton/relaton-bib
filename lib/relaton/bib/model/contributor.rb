module Relaton
  module Bib
    class Contributor < Lutaml::Model::Serializable
      class Role < Lutaml::Model::Serializable
        attribute :type, :string, values: %w[
          author performer publisher editor adapter translator distributor reazer
          owner authorizer enabler subject
        ]
        attribute :description, LocalizedMarkedUpString, collection: true, initialize_empty: true

        xml do
          root "role"
          map_attribute "type", to: :type
          map_element "description", to: :description
        end
      end

      attribute :role, Role, collection: true, initialize_empty: true
      import_model_attributes ContributionInfo

      xml do
        root "contributor"

        map_element "role", to: :role
        import_model_mappings ContributionInfo
      end
    end
  end
end
