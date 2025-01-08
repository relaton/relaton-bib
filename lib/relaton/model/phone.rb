module Relaton
  module Model
    class Phone < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :content, :string

      xml do
        root "phone"
        map_attribute "type", to: :type
        map_content to: :content
      end
    end
  end
end
