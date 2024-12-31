module Relaton
  module Bib
    class Place
      # @return [String, nil]
      attr_accessor :formatted_place, :city

      # @return [Array<Relaton::Bib::Place::RegionType>]
      attr_accessor :region, :country

      # @return [Relaton::Model::Uri, nil]
      attr_accessor :uri

      #
      # Initialize place.
      #
      # @param city [String, nil] city or formatted place should be provided
      # @param region [Array<Relaton::Bib::Place::RegionType>] region of place
      # @param country [Array<Relaton::Bib::Place::RegionType>] country of place
      # @param formatted_place [String, nil] formatted place or city should be provided
      # @param uri [Relaton::Model::Uri, nil] URI of place
      #
      def initialize(**args)
        # if formatted_place.nil? && city.nil?
        #   raise ArgumentError, "`formatted_place` or `city` should be provided"
        # end

        @city             = args[:city]
        @region           = args[:region] || []
        @country          = args[:country] || []
        @formatted_place  = args[:formatted_place]
        @uri              = args[:uri]
      end

      #
      # Render place as XML.
      #
      # @param builder [Nologiri::XML::Builder]
      #
      # def to_xml(builder)
      #   if formatted_place
      #     builder.place formatted_place
      #   else
      #     builder.place do |b|
      #       b.city city
      #       region.each { |r| b.region { r.to_xml b } }
      #       country.each { |c| b.country { c.to_xml b } }
      #     end
      #   end
      # end

      #
      # Render place as Hash.
      #
      # @return [Hash]
      #
      # def to_hash
      #   if formatted_place then formatted_place
      #   else
      #     hash = { "city" => city }
      #     hash["region"] = region.map(&:to_hash) if region.any?
      #     hash["country"] = country.map(&:to_hash) if country.any?
      #     hash
      #   end
      # end

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
        return "#{out}#{pref}.formatted_place:: #{formatted_place}\n" if formatted_place

        out += "#{pref}.city:: #{city}\n"
        out += region.map { |r| r.to_asciibib("#{pref}.region", region.size) }.join
        out + country.map { |c| c.to_asciibib("#{pref}.country", country.size) }.join
      end

      class RegionType
        STATES = {
          "AK" =>	"Alaska",
          "AL" =>	"Alabama",
          "AR" =>	"Arkansas",
          "AZ" =>	"Arizona",
          "CA" =>	"California",
          "CO" =>	"Colorado",
          "CT" =>	"Connecticut",
          "DC" =>	"District Of Columbia",
          "DE" =>	"Delaware",
          "FL" =>	"Florida",
          "GA" =>	"Georgia",
          "GU" =>	"Guam",
          "HI" =>	"Hawaii",
          "IA" =>	"Iowa",
          "ID" =>	"Idaho",
          "IL" =>	"Illinois",
          "IN" =>	"Indiana",
          "KS" =>	"Kansas",
          "KY" =>	"Kentucky",
          "LA" =>	"Louisiana",
          "MA" =>	"Massachusetts",
          "MD" =>	"Maryland",
          "ME" =>	"Maine",
          "MI" =>	"Michigan",
          "MN" =>	"Minnesota",
          "MO" =>	"Missouri",
          "MS" =>	"Mississippi",
          "MT" =>	"Montana",
          "NC" =>	"North Carolina",
          "ND" =>	"North Dakota",
          "NE" =>	"Nebraska",
          "NH" =>	"New Hampshire",
          "NJ" =>	"New Jersey",
          "NM" =>	"New Mexico",
          "NV" =>	"Nevada",
          "NY" =>	"New York",
          "OH" =>	"Ohio",
          "OK" =>	"Oklahoma",
          "OR" =>	"Oregon",
          "PA" =>	"Pennsylvania",
          "PR" =>	"Puerto Rico",
          "RI" =>	"Rhode Island",
          "SC" =>	"South Carolina",
          "SD" =>	"South Dakota",
          "TN" =>	"Tennessee",
          "TX" =>	"Texas",
          "UT" =>	"Utah",
          "VA" =>	"Virginia",
          "VI" =>	"Virgin Islands",
          "VT" =>	"Vermont",
          "WA" =>	"Washington",
          "WI" =>	"Wisconsin",
          "WV" =>	"West Virginia",
          "WY" =>	"Wyoming",
        }.freeze

        # @return [Strign] content of region
        attr_accessor :content

        # @return [Strign, nil] ISO code of region
        attr_accessor :iso

        # @return [Boolean, nil]
        attr_accessor :recommended

        #
        # Initialize region type. Name or valid US state ISO code should be provided.
        #
        # @param [String, nil] content name of region
        # @param [String, nil] iso ISO code of region
        # @param [Boolean, nil] recommended recommended region
        #
        def initialize(content: nil, iso: nil, recommended: nil)
          # unless content || STATES.key?(iso&.upcase)
          #   raise ArgumentError, "`content` or valid US state ISO code should be provided"
          # end

          @content = content || STATES[iso&.upcase]
          @iso  = iso
          @recommended = recommended
        end

        #
        # Render region type as XML.
        #
        # @param [Nokogiri::XML::Builder] builder XML builder
        #
        # def to_xml(builder)
        #   builder.parent["iso"] = iso if iso
        #   builder.parent["recommended"] = recommended.to_s unless recommended.nil?
        #   builder.text content
        # end

        #
        # Render region type as Hash.
        #
        # @return [Hash] region type as Hash
        #
        # def to_hash
        #   hash = { "content" => content }
        #   hash["iso"] = iso if iso
        #   hash["recommended"] = recommended unless recommended.nil?
        #   hash
        # end

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
          out += "#{pref}.content:: #{content}\n"
          out += "#{pref}.iso:: #{iso}\n" if iso
          out += "#{pref}.recommended:: #{recommended}\n" if recommended
          out
        end
      end
    end
  end
end
