require_relative "workgroup"

module Relaton
  module Bib
    class TechnicalCommittee
      # @return [Relaton::Bib::WorkGroup]
      attr_reader :workgroup

      # @param workgroup [Relaton::Bib::WorkGroup]
      def initialize(workgroup)
        @workgroup = workgroup
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.send(:"technical-committee") { |b| workgroup.to_xml b }
      end

      # @return [Hash]
      def to_hash
        workgroup.to_hash
      end

      # @param prefix [String]
      # @param count [Integer] number of technical committees
      # @return [String]
      def to_asciibib(prefix = "", count = 1)
        pref = prefix.empty? ? prefix : "#{prefix}."
        pref += "technical_committee"
        out = count > 1 ? "#{pref}::\n" : ""
        out += workgroup.to_asciibib pref
        out
      end
    end
  end
end
