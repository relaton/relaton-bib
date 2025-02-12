module Relaton
  module Bib
    class Note < LocalizedStringAttrs
      attribute :type, :string
      attribute :content, :string

      xml do
        root "note"
        map_attribute "type", to: :type
        map_all to: :content
      end
    end
  end
end
