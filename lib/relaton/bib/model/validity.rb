module Relaton
  module Bib
    class Validity < Lutaml::Model::Serializable
      attribute :begins, :date_time
      attribute :ends, :date_time
      attribute :revision, :date_time

      xml do
        root "validity"
        map_element "validityBegins", to: :begins
        map_element "validityEnds", to: :ends
        map_element "revision", to: :revision
      end
    end
  end
end
