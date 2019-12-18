module RelatonBib
  class Place
    # @return [String]
    attr_reader :name

    # @return [String, NilClass]
    attr_reader :uri, :region

    # @param name [String]
    # @param uri [String, NilClass]
    # @param region [String, NilClass]
    def initialize(name:, uri: nil, region: nil)
      @name   = name
      @uri    = uri
      @region = region
    end

    # @param builder [Nologiri::XML::Builder]
    def to_xml(builder)
      xml = builder.place name
      xml[:uri] = uri if uri
      xml[:region] = region if region
    end

    # @return [Hash]
    def to_hash
      if uri || region
        hash = { name: name }
        hash["uri"] = uri if uri
        hash["region"] = region if region
        hash
      else
        name
      end
    end
  end
end