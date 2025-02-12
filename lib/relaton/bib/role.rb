module Relaton
  module Bib
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
  end
end
