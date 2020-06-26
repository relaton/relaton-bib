require "relaton_bib/technical_committee"

module RelatonBib
  class EditorialGroup
    include RelatonBib

    # @return [Array<RelatonBib::TechnicalCommittee>]
    attr_accessor :technical_committee

    # @param technical_committee [Array<RelatonBib::TecnicalCommittee>]
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
  end
end
