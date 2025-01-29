module Relaton
  module Bib
    class Version < Lutaml::Model::Serializable
      attribute :revision_date, :date
      attribute :draft, :string

      xml do
        root "version"
        map_element "revision-date", to: :revision_date
        map_element "draft", to: :draft
      end
    end
  end
end
