module RelatonBib
  class Validity
    FORMAT = "%Y-%m-%d %H:%M".freeze

    # @return [Time, nil]
    attr_reader :begins

    # @return [Time, nil]
    attr_reader :ends

    # @return [Time, nil]
    attr_reader :revision

    # @param begins [Time, nil]
    # @param ends [Time, nil]
    # @param revision [Time, nil]
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
