module Relaton
  module Model
    class Validity < Lutaml::Model::Serializable
      model Bib::Validity

      attribute :begins, :date
      attribute :ends, :date
      attribute :revision, :date

      xml do
        root "validity"
        map_element "validityBegins", to: :begins
        map_element "validityEnds", to: :ends
        map_element "revision", to: :revision
      end
    end
  end
end
