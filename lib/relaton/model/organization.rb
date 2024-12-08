require_relative "organization_type"

module Relaton
  module Model
    class Organization < Lutaml::Model::Serializable
      include Relaton::Model::OrganizationType

      model Bib::Organization

      mappings[:xml].instance_eval do
        root "organization"
      end
    end
  end
end
