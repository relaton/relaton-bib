module Relaton
  module Bib
    class Note < LocalizedMarkedUpString
      attribute :type, :string

      xml do
        root "note"
        map_attribute "type", to: :type
      end

      key_value do
        map "type", to: :type
      end
    end
  end
end
