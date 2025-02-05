module Relaton
  module Bib
    class Date < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :text, :string
      attribute :from, :string
      attribute :to, :string
      attribute :at, :string # `on` is reserved word in YAML, so use `at` instead to avoid remapping key-value formats

      xml do
        root "date"
        map_attribute "type", to: :type
        map_attribute "text", to: :text
        map_element "from", to: :from
        map_element "to", to: :to
        map_element "on", to: :at
      end
    end
  end
end
