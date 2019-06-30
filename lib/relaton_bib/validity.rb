module RelatonBib
  class << self
    def validity_hash_to_bib(ret)
      ret[:validity] and ret[:validity] =
        RelatonBib::Validity.new(begins: Time.parse(ret[:validity][:begins]),
                                 ends: Time.parse(ret[:validity][:ends]),
                                 revision: Time.parse(ret[:validity][:revision]))
    end
  end

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
  end
end
