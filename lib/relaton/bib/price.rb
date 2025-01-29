module Relaton
  module Bib
    class Price < Lutaml::Model::Serializable
      attribute :currency, :string
      attribute :content, :string

      xml do
        root "price"
        map_attribute "currency", to: :currency
        map_content to: :content
      end
    end
  end
end
