module Relaton
  module Model
    class Status < Lutaml::Model::Serializable
      class Stage < Lutaml::Model::Serializable
        model Bib::Status::Stage

        attribute :abbreviation, :string
        attribute :content, :string

        xml do
          root "stage"
          map_attribute "abbreviation", to: :abbreviation
          map_content to: :content
        end
      end

      model Bib::Status

      attribute :stage, Stage
      attribute :substage, Stage
      attribute :iteration, :string

      xml do
        root "status"
        map_element "stage", to: :stage
        map_element "substage", to: :substage
        map_element "iteration", to: :iteration
      end
    end
  end
end
