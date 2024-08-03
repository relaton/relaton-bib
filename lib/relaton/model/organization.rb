module Relaton
  module Model
    class Organization < Lutaml::Model::Serializable
      include Relaton::Model::OrganizationType

      @xml_mapping.instance_eval do
        root "organization"
      end
    end
  end
end
