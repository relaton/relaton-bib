module Relaton
  module Model
    class Bdate < Shale::Mapper
      model Bib::Bdate
      attribute :type, Shale::Type::String
      attribute :text, Shale::Type::String
      attribute :from, Shale::Type::String
      attribute :to, Shale::Type::String
      attribute :on, Shale::Type::String

      xml do
        root "date"
        map_attribute "type", to: :type
        map_attribute "text", to: :text
        map_element "from", to: :from
        map_element "to", to: :to
        map_element "on", to: :on
      end
    end
  end
end
