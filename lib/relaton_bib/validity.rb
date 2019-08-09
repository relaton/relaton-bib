module RelatonBib
  class Validity
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
      format = "%Y-%m-%d %H:%M"
      builder.validity do
        builder.validityBegins begins.strftime(format) if begins
        builder.validityEnds ends.strftime(format) if ends
        builder.validityRevision revision.strftime(format) if revision
      end
    end

    # @return [Hash]
    def to_hash
      hash = {}
      hash[:begins] = begins.to_s if begins
      hash[:ends] = ends.to_s if ends
      hash[:revision] = revision.to_s if revision
      hash
    end
  end
end
