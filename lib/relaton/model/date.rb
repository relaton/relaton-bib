module Relaton
  module Model
    class Date < Shale::Mapper
      attribute :content, Shale::Type::String

      xml do
        root "date"
        map_content to: :content
      end
    end
  end
end
