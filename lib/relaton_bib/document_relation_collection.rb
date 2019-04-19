# frozen_string_literal: true

module RelatonBib
  # Document relations collection
  class DocRelationCollection < Array
    # @param relations [Array<RelatonBib::DocumentRelation, Hash>]
    # @option relations [String] :type
    # @option relations [String] :identifier
    # @option relations [String, NIllClass] :url (nil)
    # @option relations [Array<RelatonBib::BibItemLocality>] :bib_locality
    # @option relations [RelatonBib::BibliographicItem, NillClass] :bibitem (nil)
    def initialize(relations)
      super relations.map { |r| r.is_a?(Hash) ? DocumentRelation.new(r) : r }
    end

    # @return [Array<RelatonBib::DocumentRelation>]
    def replaces
      select { |r| r.type == "replace" }
    end
  end
end
