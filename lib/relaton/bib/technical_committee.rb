require_relative "workgroup"

module Relaton
  module Bib
    class TechnicalCommittee < Lutaml::Model::Serializable
      attribute :workgroup, WorkGroup

      xml do
        root "technical-committee"
        map_content to: :workgroup
      end
    end
  end
end
