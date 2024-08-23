module Relaton
  module Model
    class Organization < Lutaml::Model::Serializable
      include Relaton::Model::OrganizationType

      mappings[:xml].instance_eval do
        root "organization"
      end
    end
  end
end
