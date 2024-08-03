module Relaton
  module Model
    class Date < Lutaml::Model::Serializable
      # model Bib::Bdate

      attribute :type, Lutaml::Model::Type::String
      attribute :text, Lutaml::Model::Type::String
      attribute :from, Lutaml::Model::Type::String
      attribute :to, Lutaml::Model::Type::String
      attribute :on, Lutaml::Model::Type::String

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
