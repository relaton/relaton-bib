require "weakref"

module RelatonBib
  class Hit
    # @return [RelatonBib::HitCollection]
    attr_accessor :hit_collection

    # @return [Array<Hash>]
    attr_reader :hit

    # @param hit [Hash]
    # @param hit_collection [RelatonBib::HitCollection]
    def initialize(hit, hit_collection = nil)
      @hit            = hit
      @hit_collection = WeakRef.new hit_collection if hit_collection
    end

    # @return [String]
    def to_s
      inspect
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{format('%<id>#.14x', id: object_id << 1)} " \
        "@text=\"#{@hit_collection&.text}\" " \
        "@fetched=\"#{!@fetch.nil?}\" " \
        "@fullIdentifier=\"#{@fetch&.shortref(nil)}\" " \
        "@title=\"#{@hit[:code]}\">"
    end

    def fetch
      raise "Not implemented"
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata
    # @option opts [String, Symbol] :lang language
    # @return [String] XML
    def to_xml(**opts)
      if opts[:builder]
        fetch.to_xml(**opts)
      else
        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          fetch.to_xml(**opts.merge(builder: xml))
        end
        builder.doc.root.to_xml
      end
    end
  end
end
