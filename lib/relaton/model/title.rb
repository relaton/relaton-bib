module Relaton
  module Model
    class Title < Lutaml::Model::Serializable
      include Relaton::Model::TypedTitleString

      model Bib::Title

      @xml_mapping.instance_eval do
        root "title"
      end
    end
  end
end
