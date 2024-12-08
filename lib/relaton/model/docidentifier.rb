module Relaton
  module Model
    class Docidentifier < LocalizedString

      model ::Relaton::Bib::Docidentifier

      attribute :type, :string
      attribute :scope, :string
      attribute :primary, :string

      mappings[:xml].instance_eval do
        root "docidentifier"
        map_attribute "type", to: :type
        map_attribute "scope", to: :scope
        map_attribute "primary", to: :primary
      end
    end
  end
end
