module Relaton
  module Bib
    class Image < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :src, :string # anyURI
      attribute :mimetype, :string
      attribute :filename, :string
      attribute :width, :string
      attribute :height, :string
      attribute :alt, :string
      attribute :title, :string
      attribute :longdesc, :string # anyURI

      xml do
        root "image"
        map_attribute "id", to: :id
        map_attribute "src", to: :src
        map_attribute "mimetype", to: :mimetype
        map_attribute "filename", to: :filename
        map_attribute "width", to: :width
        map_attribute "height", to: :height
        map_attribute "alt", to: :alt
        map_attribute "title", to: :title
        map_attribute "longdesc", to: :longdesc
      end
    end
  end
end
