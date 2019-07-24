# frozen_string_literal: true

module RelatonBib
  # Document relation collection
  class DocRelationCollection < Array
    # @param relation [Array<RelatonBib::DocumentRelation, Hash>]
    # @option relation [String] :type
    # @option relation [String] :identifier
    # @option relation [String, NIllClass] :url (nil)
    # @option relation [Array<RelatonBib::BibItemLocality>] :bib_locality
    # @option relation [RelatonBib::BibliographicItem, NillClass] :bibitem (nil)
    def initialize(relation)
      super relation.map { |r| r.is_a?(Hash) ? DocumentRelation.new(r) : r }
    end

    # @return [Array<RelatonBib::DocumentRelation>]
    def replaces
      select { |r| r.type == "replace" }
    end
  end
end
