require "isoics"

module Relaton
  module Bib
    class ICS < Lutaml::Model::Serializable
      attribute :code, :string
      attribute :text, :string

      xml do
        root "ics"
        map_element "code", to: :code
        map_element "text", to: :text
      end

      def text
        val = @text
        return val if val && !val.empty?

        Isoics.fetch(code)&.description if code
      end
    end
  end
end
