require "relaton_bib/technical_committee"

module RelatonBib
  class EditorialGroup
    include RelatonBib

    # @return [Array<RelatonBib::TechnicalCommittee>]
    attr_accessor :technical_committee

    # @param technical_committee [Array<RelatonBib::TechnicalCommittee>]
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
