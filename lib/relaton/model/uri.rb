module Relaton
  module Model
    # Contact URI
    class Uri < Lutaml::Model::Serializable
      # model Relaton::Bib::Uri

      attribute :type, :string
      attribute :content, :string

      xml do
        map_attribute "type", to: :type
        map_content to: :content
      end
    end
  end
end
