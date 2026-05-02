require_relative "type/plain_date"

module Relaton
  module Bib
    class Version < Lutaml::Model::Serializable
      attribute :revision_date, PlainDate
      attribute :draft, :string

      xml do
        root "version"
        map_element "revision-date", to: :revision_date
        map_element "draft", to: :draft
      end
    end
  end
end
