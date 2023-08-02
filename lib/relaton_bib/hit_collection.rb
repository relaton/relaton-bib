require "forwardable"

module RelatonBib
  class HitCollection
    extend Forwardable

    def_delegators :@array, :<<, :[], :first, :empty?, :any?, :size, :each,
                   :each_slice, :reduce, :map

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

    #
    # Fetches hits from the data source
    #
    # @return [self] self object
    #
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

    #
    # Renders the collection as XML
    #
    # @param opts [Hash] options
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata render bibdata if true
    # @option opts [String, Symbol] :lang language
    #
    # @return [String] XML representation of the collection
    #
    def to_xml(**opts)
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.documents do
          @array.each do |hit|
            hit.fetch
            hit.to_xml(**opts.merge(builder: xml))
          end
        end
      end
      builder.to_xml
    end

    #
    # Selects matching hits and returns a new collection
    #
    # @param [Proc] &block proc to select hits
    #
    # @return [RelatonBib::HitCollection] new hit collection
    #
    def select(&block)
      me = deep_dup
      array_dup = instance_variable_get(:@array).deep_dup
      me.instance_variable_set(:@array, array_dup)
      array_dup.select!(&block)
      array_dup.each { |h| h.hit_collection = WeakRef.new me }
      me
    end

    def reduce!(sum, &block)
      @array = @array.reduce sum, &block
      self
    end

    #
    # Returns String representation of the collection
    #
    # @return [String] String representation of the collection
    #
    def to_s
      inspect
    end

    #
    # Returns String representation of the collection
    #
    # @return [String] String representation of the collection
    #
    def inspect
      "<#{self.class}:#{format('%#.14x', object_id << 1)} @ref=#{@text} @fetched=#{@fetched}>"
    end
  end
end
