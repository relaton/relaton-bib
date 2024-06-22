# frozen_string_literal: true

module Relaton
  module Bib
    # Document relation collection
    class DocRelationCollection
      extend Forwardable

      def_delegators :@array, :<<, :[], :first, :last, :empty?, :any?, :size,
                     :each, :detect, :map, :reduce, :length, :unshift, :max_by

      # @param relation [Array<Relaton::Bib::DocumentRelation, Hash>]
      # @option relation [String] :type
      # @option relation [String] :identifier
      # @option relation [String, NIllClass] :url (nil)
      # @option relation [Array<Relaton::Bib::Locality, Relaton::Bib::LocalityStack>] :locality
      # @option relation [Array<Relaton::Bib::SourceLocality, Relaton::Bib::SourceLocalityStack>] :source_locality
      # @option relation [Relaton::Bib::Item, NillClass] :bibitem (nil)
      def initialize(relation)
        @array = relation.map { |r| r.is_a?(Hash) ? DocumentRelation.new(**r) : r }
      end

      #
      # Returns new DocumentRelationCollection with selected relations.
      #
      # @example Select relations with type "obsoletes"
      #   relations.select { |r| r.type == "obsoletes" }
      #   #=> <Relaton::Bib::DocRelationCollection:0x00007f9a0191d5f0 @array=[...]>
      #
      # @return [Relaton::Bib::DocRelationCollection] new DocumentRelationCollection
      #   with selected relations
      #
      def select(&block)
        arr = @array.select(&block)
        self.class.new arr
      end

      # @todo We don't have replace type anymore. Suppose we should update this
      #   method or delete it.
      #
      # @return [Relaton::Bib::DocRelationCollection]
      def replaces
        DocRelationCollection.new(@array.select { |r| r.type == "replace" })
      end

      # @param prefix [String]
      # @return [String]
      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "relation" : "#{prefix}.relation"
        out = ""
        @array.each do |r|
          out += size > 1 ? "#{pref}::\n" : ""
          out += r.to_asciibib pref
        end
        out
      end
    end
  end
end
