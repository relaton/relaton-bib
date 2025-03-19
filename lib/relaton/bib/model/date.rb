module Relaton
  module Bib
    class Date < Lutaml::Model::Serializable
      attribute :type, :string, values: %w[
        published accessed created implemented obsoleted confirmed updated
        corrected issued transmitted copied unchanged circulated adapted
        vote-started vote-ended announced stable-until
      ]
      attribute :text, :string
      choice(min: 1, max: 2) do
        choice(min: 1, max: 2) do
          attribute :from, :string
          attribute :to, :string
        end
        # `on` is reserved word in YAML, so use `at` instead to avoid remapping key-value formats
        attribute :at, :string
      end

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
