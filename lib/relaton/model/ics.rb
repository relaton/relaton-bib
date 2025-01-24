module Relaton
  module Model
    class ICS < Lutaml::Model::Serializable
      model Bib::ICS

      attribute :code, :string
      attribute :text, :string

      xml do
        root "ics"
        map_element "code", to: :code
        map_element "text", to: :text
      end
    end
  end
end
