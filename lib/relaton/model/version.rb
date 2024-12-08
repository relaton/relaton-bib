module Relaton
  module Model
    class Version < Lutaml::Model::Serializable
      model Relaton::Bib::Bversion

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
