require_relative "postal"

module Relaton
  module Bib
    module BibXML
      class Address < Lutaml::Model::Serialize
        attribute :postal, Postal
        attribute :phone, :string
        attribute :faximile, :string
        attribute :email, AsciiContent
        attribute :uri, :string

        xml do
          map_element "postal", to: :postal
          map_element "phone", to: :phone
          map_element "faximile", to: :faximile
          map_element "email", to: :email
          map_element "uri", to: :uri
        end
      end
    end
  end
end
