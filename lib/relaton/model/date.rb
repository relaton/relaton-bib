module Relaton
  module Model
    class Date < Lutaml::Model::Serializable
      model Bib::Date

      attribute :type, :string
      attribute :text, :string
      attribute :from, :string
      attribute :to, :string
      attribute :on, :string

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
