module Relaton
  module Bib
    class WorkGroup < Lutaml::Model::Serializable
      attribute :number, :string
      attribute :type, :string
      attribute :identifier, :string
      attribute :prefix, :string
      attribute :content, :string

      xml do
        root "workgroup"
        map_attribute "number", to: :number
        map_attribute "type", to: :type
        map_attribute "identifier", to: :identifier
        map_attribute "prefix", to: :prefix
        map_content to: :content
      end
    end
  end
end
