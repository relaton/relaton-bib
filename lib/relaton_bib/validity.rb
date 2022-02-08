module RelatonBib
  class Validity
    FORMAT = "%Y-%m-%d %H:%M".freeze

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
        builder.revision revision.strftime(FORMAT) if revision
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

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? "validity." : "#{prefix}.validity."
      out = ""
      out += "#{pref}begins:: #{begins.strftime(FORMAT)}\n" if begins
      out += "#{pref}ends:: #{ends.strftime(FORMAT)}\n" if ends
      out += "#{pref}revision:: #{revision.strftime(FORMAT)}\n" if revision
      out
    end
  end
end
