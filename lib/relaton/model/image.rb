module Relaton
  module Model
    class Image < Shale::Mapper
      model Relaton::Bib::Image

      attribute :id, Shale::Type::String
      attribute :src, Shale::Type::String # anyURI
      attribute :mimetype, Shale::Type::String
      attribute :filename, Shale::Type::String
      attribute :width, Shale::Type::String
      attribute :height, Shale::Type::String
      attribute :alt, Shale::Type::String
      attribute :title, Shale::Type::String
      attribute :longdesc, Shale::Type::String # anyURI

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
