module Relaton
  module Module
    class Abbreviation < Lutaml::Model::Serializable
      include LocalizedString

      @xml_mapping.instance_eval do
        root "abbreviation"
      end
    end
  end
end
