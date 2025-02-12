module Relaton
  module Bib
    class Size < Lutaml::Model::Serializable
      class Value < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          root "value"
          map_attribute "type", to: :type
          map_content to: :content
        end
      end

      attribute :value, Value, collection: (1..)

      xml do
        root "size"
        map_element "value", to: :value
      end
    end
  end
end
