module Relaton
  module Bib
    class Title < LocalizedString
      attribute :type, :string
      attribute :format, :string # @DEPRECATED

      xml do
        map_attribute "type", to: :type
        map_attribute "format", to: :format
      end
    end
  end
end
