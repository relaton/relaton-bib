# frozen_string_literal: true

module Relaton
  module Bib
    # Document relation collection
    class RelationCollection
      extend Forwardable

      def_delegators :@array, :[], :first, :last, :empty?, :any?, :size, :count,
                     :each, :detect, :map, :reduce, :length, :unshift, :max_by

      # @param relation [Array<Relaton::Bib::DocumentRelation>]
      def initialize(relation = [])
        @array = relation
      end

      def <<(relation)
        @array << relation
        self
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
        self.class.new relation: arr
      end

      # @todo We don't have replace type anymore. Suppose we should update this
      #   method or delete it.
      #
      # @return [Relaton::Bib::DocRelationCollection]
      def replaces
        RelationCollection.new(@array.select { |r| r.type == "replace" })
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

      # This is needed for lutaml-model to treat RelationCollection instance as Array
      def is_a?(klass)
        klass == Array || super
      end
    end
  end
end
