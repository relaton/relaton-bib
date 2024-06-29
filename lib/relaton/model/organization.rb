module Relaton
  module Model
    class Organization < Shale::Mapper
      include Relaton::Model::OrganizationType

      @xml_mapping.instance_eval do
        root "organization"
      end
    end
  end
end
