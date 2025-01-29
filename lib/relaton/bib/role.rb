module Relaton
  module Bib
    class Role < Lutaml::Model::Serializable
      class Description < LocalizedString
        mappings[:xml].instance_eval do
          root "description"
        end
      end

      attribute :type, :string
      attribute :description, Description, collection: true

      xml do
        root "role"
        map_attribute "type", to: :type
        map_element "description", to: :description
      end
    end
  end
end
