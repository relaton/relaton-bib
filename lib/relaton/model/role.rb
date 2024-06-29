module Relaton
  module Model
    class Role < Shale::Mapper
      class Description < Shale::Mapper
        include LocalizedMarkedUpString

        @xml_mapping.instance_eval do
          root "description"
        end
      end

      attribute :type, Shale::Type::String
      attribute :description, Description, collection: true

      xml do
        root "role"
        map_attribute "type", to: :type
        map_element "description", to: :description
      end
    end
  end
end
