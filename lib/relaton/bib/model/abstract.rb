module Relaton
  module Bib
    class Abstract < LocalizedMarkedUpString
      attribute :format, :string

      xml do
        root "abstract"
        map_attribute "format", to: :format
      end

      key_value do
        map "format", to: :format
      end
    end
  end
end
