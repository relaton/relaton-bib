# frozen_string_literal: true

require "forwardable"

module RelatonBib
  # Document relation collection
  class DocRelationCollection
    extend Forwardable

    def_delegators :@array, :<<, :[], :first, :last, :empty?, :any?, :size,
      :each, :detect, :map, :length

    # @param relation [Array<RelatonBib::DocumentRelation, Hash>]
    # @option relation [String] :type
    # @option relation [String] :identifier
    # @option relation [String, NIllClass] :url (nil)
    # @option relation [Array<RelatonBib::Locality,
    #                   RelatonBib::LocalityStack>] :locality
    # @option relation [Array<RelatonBib::SourceLocality,
    #                   RelatonBib::SourceLocalityStack>] :source_locality
    # @option relation [RelatonBib::BibliographicItem, NillClass] :bibitem (nil)
    def initialize(relation)
      @array =  relation.map { |r| r.is_a?(Hash) ? DocumentRelation.new(r) : r }
    end

    # @return [RelatonBib::DocRelationCollection]
    def replaces
      DocRelationCollection.new @array.select { |r| r.type == "replace" }
    end
  end
end
