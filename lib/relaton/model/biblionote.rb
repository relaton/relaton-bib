module Relaton
  module Model
    class Biblionote < LocalizedStringAttrs
      model Bib::Note

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
