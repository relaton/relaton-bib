# frozen_string_literal: true

module Relaton
  module Bib
    # Organization.
    class Organization
    end

    class Organization
      # Subdivision of an organization.
      class Subdivision < Organization
        attr_accessor :type

        def initialize(**args)
          super
          @type = args[:type]
        end
      end

      # Organization identifier.
      class Identifier
        # @return [String]
        attr_accessor :type, :content

        # @param type [String]
        # @param content [String]
        def initialize(**args)
          @type     = args[:type]
          @content  = args[:content]
        end

        # @param builder [Nokogiri::XML::Builder]
        # def to_xml(builder)
        #   builder.identifier(content, type: type)
        # end

        # @return [Hash]
        # def to_hash
        #   { "type" => type, "id" => content }
        # end

        # @param prefix [String]
        # @param count [Integer]
        # @return [String]
        def to_asciibib(prefix = "", count = 1)
          pref = prefix.empty? ? prefix : "#{prefix}."
          out = count > 1 ? "#{pref}identifier::\n" : ""
          out += "#{pref}identifier.type:: #{type}\n"
          out += "#{pref}identifier.content:: #{content}\n"
          out
        end
      end

      # class Name < LocalizedString
      #   attr_accessor :type

      #   def initialize(**args)
      #     super
      #     @type = args[:type]
      #   end
      # end

      # @return [Array<Relaton::Bib::Organization::Name>]
      attr_accessor :name

      # @return [Relaton::Bib::LocalizedString, nil]
      attr_accessor :abbreviation

      # @return [Array<Relaton::Bib::TypedLocalizedString>]
      attr_accessor :subdivision

      # @return [Array<Relaton::Bib::Organization::Identifier>]
      attr_accessor :identifier

      attr_accessor :address, :phone, :email, :uri

      # @return [Relaton::Bib::Image, nil]
      attr_accessor :logo

      # @param name [Array<RelatoBib::TypedLocalizedString>]
      # @param abbreviation [RelatoBib::LocalizedString]
      # @param subdivision [Array<RelatoBib::Organization::Subdivision>]
      # @param identifier [Array<Relaton::Bib::Organization::Identifier>]
      # @param address [Array<Relaton::Model::Address>]
      # @param phone [Array<Relaton::Model::Phone>]
      # @param email [Array<String>]
      # @param uri [Array<Relaton::Model::Uri>]
      # @param logo [Relaton::Bib::Image, nil]
      def initialize(**args) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        @name = args[:name] || []
        @abbreviation = args[:abbreviation]
        @subdivision  = args[:subdivision] || []
        @identifier   = args[:identifier] || []
        @address      = args[:address] || []
        @phone        = args[:phone] || []
        @email        = args[:email] || []
        @uri          = args[:uri] || []
        @logo         = args[:logo]
      end

      # @return [Hash]
      # def to_hash # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
      #   hash = { "name" => single_element_array(name) }
      #   hash["abbreviation"] = abbreviation.to_hash if abbreviation
      #   hash["identifier"] = single_element_array(identifier) if identifier&.any?
      #   if subdivision&.any?
      #     hash["subdivision"] = single_element_array(subdivision)
      #   end
      #   hash["logo"] = logo.to_hash if logo
      #   { "organization" => hash.merge(super) }
      # end

      # @param prefix [String]
      # @param count [Integer]
      # @return [String]
      def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        pref = prefix.sub(/\*$/, "organization")
        out = count > 1 ? "#{pref}::\n" : ""
        name.each { |n| out += n.to_asciibib "#{pref}.name", name.size }
        out += abbreviation.to_asciibib "#{pref}.abbreviation" if abbreviation
        subdivision.each do |sd|
          out += "#{pref}.subdivision::" if subdivision.size > 1
          out += sd.to_asciibib "#{pref}.subdivision"
        end
        identifier.each { |n| out += n.to_asciibib pref, identifier.size }
        out += super pref
        out += logo.to_asciibib "#{pref}.logo" if logo
        out
      end
    end
  end
end
