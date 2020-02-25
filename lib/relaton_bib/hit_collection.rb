require "forwardable"

module RelatonBib
  class HitCollection
    extend Forwardable

    def_delegators :@array, :<<, :[], :first, :empty?, :any?, :size, :each, :each_slice

    # @return [TrueClass, FalseClass]
    attr_reader :fetched

    # @return [String]
    attr_reader :text

    # @return [String]
    attr_reader :year

    # @param text [String] reference to search
    def initialize(text, year = nil)
      @array = []
      @text = text
      @year = year
      @fetched = false
    end

    # @return [RelatonIso::HitCollection]
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

    def to_xml(**opts)
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.documents do
          @array.each do |hit|
            hit.fetch
            hit.to_xml xml, **opts
          end
        end
      end
      builder.to_xml
    end

    def select(&block)
      me = self.deep_dup
      array_dup = self.instance_variable_get(:@array).deep_dup
      me.instance_variable_set(:@array, array_dup)
      array_dup.select!(&block)
      me
    end

    def reduce!(sum, &block)
      @array = @array.reduce sum, &block
      self
    end

    def to_s
      inspect
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{format('%#.14x', object_id << 1)} @ref=#{@text} @fetched=#{@fetched}>"
    end
  end
end
