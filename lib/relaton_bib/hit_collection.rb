module RelatonBib
  class HitCollection < Array
    # @return [TrueClass, FalseClass]
    attr_reader :fetched

    # @return [String]
    attr_reader :text

    # @return [String]
    attr_reader :year

    # @return [Iecbib::HitCollection]
    def fetch
      workers = WorkersPool.new 4
      workers.worker(&:fetch)
      each do |hit|
        workers << hit
      end
      workers.end
      workers.result
      @fetched = true
      self
    end

    def to_s
      inspect
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{format('%#.14x', object_id << 1)} @fetched=#{@fetched}>"
    end
  end
end
