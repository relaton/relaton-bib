require_relative "organization"
require_relative "address"

module Relaton
  module Bib
    module BibXML
      class Author < Lutaml::Model::Serialize
        attribute :ascii_fullname, :string
        attribute :ascii_initials, :string
        attribute :ascii_surname, :string
        attribute :fullname, :string
        attribute :initials, :string
        attribute :role, :string, values: %w[editor]
        attribute :surname, :string
        attribute :organization, Organization
        attirbute :address, Address

        xml do
          root "author"
          map_attribute "asciiFullname", to: :ascii_fullname
          map_attribute "asciiInitials", to: :ascii_initials
          map_attribute "asciiSurname", to: :ascii_surname
          map_attribute "fullname", to: :fullname
          map_attribute "initials", to: :initials
          map_attribute "role", to: :role
          map_attribute "surname", to: :surname
          map_element "organization", to: :organization
          map_element "address", to: :address
        end
      end
    end
  end
end
