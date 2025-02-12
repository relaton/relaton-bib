require_relative "organization_type"

module Relaton
  module Bib
    class Organization < Lutaml::Model::Serializable
      include OrganizationType

      xml do
        root "organization"
      end
    end
  end
end
