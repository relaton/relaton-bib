require "isoics"

module Relaton
  module Bib
    class ICS < Lutaml::Model::Serializable
      attribute :code, :string
      attribute :text, method: :get_text

      xml do
        root "ics"
        map_element "code", to: :code
        map_element "text", to: :text
      end

      def get_text
        return @text if @text && !@text.empty?

        Isoics.fetch(code)&.description if code
      end
    end
  end
end
