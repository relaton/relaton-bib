require_relative "workgroup"

module Relaton
  module Bib
    class EditorialGroup < Lutaml::Model::Serializable
      attribute :technical_committee, WorkGroup, collection: true

      xml do
        root "editorialgroup"
        map_element "technical-committee", to: :technical_committee
      end
    end
  end
end
