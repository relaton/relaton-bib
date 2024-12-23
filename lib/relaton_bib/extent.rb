module RelatonBib
  class Extent
    attr_accessor :locality

    #
    # @param [Array<RelatonBib::Locality, RelatonBib::LocalityStack>] locality
    #
    def initialize(locality)
      @locality = locality
    end

    def to_xml(builder)
      builder.extent do |b|
        locality.each { |l| l.to_xml(b) }
      end
    end

    def to_hash
      hash = Hash.new { |h, k| h[k] = [] }
      locality.each_with_object(hash) do |l, obj|
        k, v = l.to_hash.first
        obj[k] << v
      end
    end

    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? "extent" : "#{prefix}.extent"
      out = count > 1 ? "#{pref}::\n" : ""
      locality.each do |l|
        out += l.to_asciibib(pref, locality.size)
      end
      out
    end

    def to_bibtex(item)
      locality.map { |l| l.to_bibtex(item) }.join
    end
  end
end
