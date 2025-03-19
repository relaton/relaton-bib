module Relaton
  module Bib
    class Edition < Lutaml::Model::Serializable
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
