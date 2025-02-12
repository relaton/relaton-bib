module Relaton
  module Bib
    class Docidentifier < LocalizedMarkedUpString
      attribute :type, :string
      attribute :scope, :string
      attribute :primary, :boolean

      xml do
        map_attribute "type", to: :type
        map_attribute "scope", to: :scope
        map_attribute "primary", to: :primary
      end
    end
  end
end
