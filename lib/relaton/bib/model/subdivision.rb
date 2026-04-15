module Relaton
  module Bib
    class Subdivision < Lutaml::Model::Serializable
      include OrganizationType

      attribute :type, :string
      attribute :subtype, :string

      xml do
        root "subdivision"
        map_attribute "type", to: :type
        map_attribute "subtype", to: :subtype
      end

      key_value do
        map "type", to: :type
        map "subtype", to: :subtype
      end
    end
  end
end
