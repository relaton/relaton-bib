module Relaton
  module Module
    class Abbreviation < Lutaml::Model::Serializable
      include LocalizedString

      mappings[:xml].instance_eval do
        root "abbreviation"
      end
    end
  end
end
