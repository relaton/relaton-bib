module RelatonBib
  class Hit
    # @return [Array<Hash>]
    attr_reader :hit

    # @param hit [Hash]
    # @param hit_collection [RelatonNist:HitCollection]
    def initialize(hit, hit_collection = nil)
      @hit            = hit
      @hit_collection = hit_collection
    end

    # @return [String]
    def to_s
      inspect
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{format('%#.14x', object_id << 1)} "\
      "@text=\"#{@hit_collection&.text}\" "\
      "@fetched=\"#{!@fetch.nil?}\" "\
      "@fullIdentifier=\"#{@fetch&.shortref(nil)}\" "\
      "@title=\"#{@hit[:code]}\">"
    end

    # @return [String]
    def to_xml(**opts)
      fetch.to_xml **opts
    end
  end
end
