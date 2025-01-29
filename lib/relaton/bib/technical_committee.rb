require_relative "workgroup"

module Relaton
  module Model
    class TechnicalCommittee < Lutaml::Model::Serializable
      model Bib::TechnicalCommittee

      attribute :workgroup, WorkGroup

      xml do
        root "technical-committee"
        map_content to: :workgroup
      end
    end
  end
end
