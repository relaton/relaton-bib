module Relaton
  module Model
    class Image < Lutaml::Model::Serializable
      model Relaton::Bib::Image

      attribute :id, Lutaml::Model::Type::String
      attribute :src, Lutaml::Model::Type::String # anyURI
      attribute :mimetype, Lutaml::Model::Type::String
      attribute :filename, Lutaml::Model::Type::String
      attribute :width, Lutaml::Model::Type::String
      attribute :height, Lutaml::Model::Type::String
      attribute :alt, Lutaml::Model::Type::String
      attribute :title, Lutaml::Model::Type::String
      attribute :longdesc, Lutaml::Model::Type::String # anyURI

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
