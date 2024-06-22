module Relaton
  module Model
    class Bookmark < Shale::Mapper
      attribute :id, Shale::Type::String

      xml do
        root "bookmark"
        map_attribute "id", to: :id
      end
    end
  end
end
