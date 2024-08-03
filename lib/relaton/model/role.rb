module Relaton
  module Model
    class Role < Lutaml::Model::Serializable
      class Description < Lutaml::Model::Serializable
        include LocalizedMarkedUpString

        @xml_mapping.instance_eval do
          root "description"
        end
      end

      attribute :type, Lutaml::Model::Type::String
      attribute :description, Description, collection: true

      xml do
        root "role"
        map_attribute "type", to: :type
        map_element "description", to: :description
      end
    end
  end
end
