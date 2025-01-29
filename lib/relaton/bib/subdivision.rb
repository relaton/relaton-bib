module Relaton
  module Bib
    class Subdivision < Lutaml::Model::Serializable
      include OrganizationType

      attribute :type, :string

      mappings[:xml].instance_eval do
        root "subdivision"
        map_attribute "type", to: :type
      end
    end
  end
end
