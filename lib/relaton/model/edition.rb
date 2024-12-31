module Relaton
  module Model
    class Edition < Lutaml::Model::Serializable
      model Bib::Edition

      attribute :number, :string
      attribute :content, :string

      xml do
        root "edition"
        map_attribute "number", to: :number
        map_content to: :content
      end
    end
  end
end
