module Relaton
  module Model
    class Price < Lutaml::Model::Serializable
      model Bib::Price

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
