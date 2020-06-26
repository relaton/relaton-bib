require "relaton_bib/workgroup"

module RelatonBib
  class TechnicalCommittee
    # @return [RelatonBib::WorkGroup]
    attr_reader :workgroup

    # @param workgroup [RelatonBib::WorkGroup]
    def initialize(workgroup)
      @workgroup = workgroup
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.send "technical-committee" do |b|
        workgroup.to_xml b
      end
    end

    # @return [Hash]
    def to_hash
      workgroup.to_hash
    end
  end
end
