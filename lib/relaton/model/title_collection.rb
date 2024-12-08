module Relaton
  module Model
    class TitleCollection < Lutaml::Model::Serializable
      model Relaton::Bib::TitleCollection

      attribute :title, Title, collection: true

      xml do
        map_content to: :title
      end
    end
  end
end
