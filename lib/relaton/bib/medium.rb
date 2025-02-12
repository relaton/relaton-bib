module Relaton
  module Bib
    class Medium < Lutaml::Model::Serializable
      attribute :content, :string
      attribute :genre, :string
      attribute :form, :string
      attribute :carrier, :string
      attribute :size, :string
      attribute :scale, :string

      xml do
        root "medium"
        map_element "content", to: :content
        map_element "genre", to: :genre
        map_element "form", to: :form
        map_element "carrier", to: :carrier
        map_element "size", to: :size
        map_element "scale", to: :scale
      end
    end
  end
end
