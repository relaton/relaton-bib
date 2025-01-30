module Relaton
  module Bib
    class DocidentifierType < LocalizedString
      attribute :type, :string
      attribute :scope, :string
      attribute :primary, :boolean

      mappings[:xml].instance_eval do
        map_attribute "type", to: :type
        map_attribute "scope", to: :scope
        map_attribute "primary", to: :primary
      end
    end
  end
end
