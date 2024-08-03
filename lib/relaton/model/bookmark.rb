module Relaton
  module Model
    class Bookmark < Lutaml::Model::Serializable
      attribute :id, Lutaml::Model::Type::String

      xml do
        root "bookmark"
        map_attribute "id", to: :id
      end
    end
  end
end
