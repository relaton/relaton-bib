require_relative "organization_type"

module Relaton
  module Bib
    class Organization < Lutaml::Model::Serializable
      include OrganizationType

      mappings[:xml].instance_eval do
        root "organization"
      end
    end
  end
end
