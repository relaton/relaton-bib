module Relaton
  module Model
    class Title < Lutaml::Model::Serializable
      include Relaton::Model::TypedTitleString

      model Bib::Title

      mappings[:xml].instance_eval do
        root "title"
      end
    end
  end
end
