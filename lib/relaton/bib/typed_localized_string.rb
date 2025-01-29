module Relaton
  module Bib
    class TypedLocalizedString < LocalizedString
      model Bib::TypedLocalizedString

      attribute :type, :string

      mappings[:xml].instance_eval do
        map_attribute "type", to: :type
      end
    end
  end
end
