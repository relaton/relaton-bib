module Relaton
  module Bib
    class Role < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :description, LocalizedMarkedUpString, collection: true

      xml do
        root "role"
        map_attribute "type", to: :type
        map_element "description", to: :description
      end
    end
  end
end
