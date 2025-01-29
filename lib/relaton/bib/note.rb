module Relaton
  module Bib
    class Note < LocalizedStringAttrs
      attribute :type, :string
      attribute :content, :string

      mappings[:xml].instance_eval do
        root "note"
        map_attribute "type", to: :type
        map_content to: :content
      end
    end
  end
end
