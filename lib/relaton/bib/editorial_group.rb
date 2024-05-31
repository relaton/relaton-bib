require_relative "technical_committee"

module Relaton
  module Bib
    class EditorialGroup
      # include Relaton

      # @return [Array<Relaton::Bib::TechnicalCommittee>]
      attr_accessor :technical_committee

      # @param technical_committee [Array<Relaton::Bib::TechnicalCommittee>]
      def initialize(technical_committee)
        @technical_committee = technical_committee
      end

      # @param builder [Nokogigi::XML::Builder]
      def to_xml(builder)
        builder.editorialgroup do |b|
          technical_committee.each { |tc| tc.to_xml b }
        end
      end

      # @return [Hash]
      def to_hash
        single_element_array technical_committee
      end

      # @param prefix [String]
      # @return [String]
      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "editorialgroup" : "#{prefix}.editorialgroup"
        technical_committee.map do |tc|
          tc.to_asciibib pref, technical_committee.size
        end.join
      end

      # @return [true]
      def presence?
        technical_committee.any?
      end
    end
  end
end
