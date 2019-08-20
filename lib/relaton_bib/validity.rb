module RelatonBib
  class Validity
    FORMAT = "%Y-%m-%d %H:%M"

    # @return [Time, NilClass]
    attr_reader :begins

    # @return [Time, NilClass]
    attr_reader :ends

    # @return [Time, NilClass]
    attr_reader :revision

    # @param begins [Time, NilClass]
    # @param ends [Time, NilClass]
    # @param revision [Time, NilClass]
    def initialize(begins: nil, ends: nil, revision: nil)
      @begins   = begins
      @ends     = ends
      @revision = revision
    end

    # @param [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.validity do
        builder.validityBegins begins.strftime(FORMAT) if begins
        builder.validityEnds ends.strftime(FORMAT) if ends
        builder.validityRevision revision.strftime(FORMAT) if revision
      end
    end

    # @return [Hash]
    def to_hash
      hash = {}
      hash["begins"] = begins.strftime(FORMAT) if begins
      hash["ends"] = ends.strftime(FORMAT) if ends
      hash["revision"] = revision.strftime(FORMAT) if revision
      hash
    end
  end
end
