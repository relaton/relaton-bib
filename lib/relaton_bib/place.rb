module RelatonBib
  class Place
    # @return [String, nil]
    attr_reader :name, :city

    # @return [Array<RelatonBib::Place::RegionType>]
    attr_reader :region, :country

    #
    # Initialize place.
    #
    # @param name [String, nil] name of place, name or city should be provided
    # @param city [String, nil] name of city, city or name should be provided
    # @param region [Array<RelatonBib::Place::RegionType>] region of place
    # @param country [Array<RelatonBib::Place::RegionType>] country of place
    #
    def initialize(name: nil, city: nil, region: [], country: []) # rubocop:disable Metrics/CyclomaticComplexity
      if name.nil? && city.nil?
        raise ArgumentError, "`name` or `city` should be provided"
      end

      @name    = name
      @city    = city
      @region  = region.map { |r| r.is_a?(Hash) ? RegionType.new(**r) : r }
      @country = country.map { |c| c.is_a?(Hash) ? RegionType.new(**c) : c }
    end

    #
    # Render place as XML.
    #
    # @param builder [Nologiri::XML::Builder]
    #
    def to_xml(builder)
      if name
        builder.place name
      else
        builder.place do |b|
          b.city city
          region.each { |r| b.region { r.to_xml b } }
          country.each { |c| b.country { c.to_xml b } }
        end
      end
    end

    #
    # Render place as Hash.
    #
    # @return [Hash]
    #
    def to_h
      if name then name
      else
        hash = { "city" => city }
        hash["region"] = region.map(&:to_h) if region.any?
        hash["country"] = country.map(&:to_h) if country.any?
        hash
      end
    end

    #
    # Render place as AsciiBib.
    #
    # @param prefix [String]
    # @param count [Integer] number of places
    #
    # @return [Stirng]
    #
    def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize
      pref = prefix.empty? ? "place" : "#{prefix}.place"
      out = count > 1 ? "#{pref}::\n" : ""
      return "#{out}#{pref}.name:: #{name}\n" if name

      out += "#{pref}.city:: #{city}\n"
      out += region.map { |r| r.to_asciibib("#{pref}.region", region.size) }.join
      out + country.map { |c| c.to_asciibib("#{pref}.country", country.size) }.join
    end

    class RegionType
      # @return [Strign] name of region
      attr_reader :name

      # @return [Strign, nil] ISO code of region
      attr_reader :iso

      # @return [Boolean, nil] <description>
      attr_reader :recommended

      #
      # Initialize region type.
      #
      # @param [String] name name of region
      # @param [String, nil] iso ISO code of region
      # @param [Boolean, nil] recommended recommended region
      #
      def initialize(name:, iso: nil, recommended: nil)
        @name = name
        @iso  = iso
        @recommended = recommended
      end

      #
      # Render region type as XML.
      #
      # @param [Nokogiri::XML::Builder] builder XML builder
      #
      def to_xml(builder)
        builder.parent["iso"] = iso if iso
        builder.parent["recommended"] = recommended.to_s unless recommended.nil?
        builder.text name
      end

      #
      # Render region type as Hash.
      #
      # @return [Hash] region type as Hash
      #
      def to_h
        hash = { "name" => name }
        hash["iso"] = iso if iso
        hash["recommended"] = recommended unless recommended.nil?
        hash
      end

      #
      # Render region type as AsciiBib.
      #
      # @param [String] pref prefix
      # @param [Integer] count number of region types
      #
      # @return [String] region type as AsciiBib
      #
      def to_asciibib(pref, count = 1) # rubocop:disable Metrics/AbcSize
        out = count > 1 ? "#{pref}::\n" : ""
        out += "#{pref}.name:: #{name}\n"
        out += "#{pref}.iso:: #{iso}\n" if iso
        out += "#{pref}.recommended:: #{recommended}\n" if recommended
        out
      end
    end
  end
end
