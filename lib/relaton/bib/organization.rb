# frozen_string_literal: true

module Relaton
  module Bib
    # Organization.
    class Organization
      # Organization identifier.
      class Identifier
        # @return [String]
        attr_accessor :type, :content

        # @param type [String]
        # @param content [String]
        def initialize(**args)
          @type  = args[:type]
          @content = args[:content]
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

      class Name < LocalizedString
        attr_accessor :type

        def initialize(**args)
          super
          @type = args[:type]
        end
      end

      # @return [Array<Relaton::Bib::Organization::Name>]
      attr_accessor :name

      # @return [Relaton::Bib::LocalizedString, nil]
      attr_accessor :abbreviation

      # @return [Array<Relaton::Bib::LocalizedString>]
      attr_accessor :subdivision

      # @return [Array<Relaton::Bib::Organization::Identifier>]
      attr_accessor :identifier

      # @return [Array<Relaton::Bib::Contact>]
      attr_accessor :contact

      # @return [Relaton::Bib::Image, nil]
      attr_accessor :logo

      # @param name [Array<RelatoBib::Organization::Name>]
      # @param abbreviation [RelatoBib::LocalizedString]
      # @param subdivision [Array<RelatoBib::LocalizedString>]
      # @param identifier [Array<Relaton::Bib::Organization::Identifier>]
      # @param contact [Array<Relaton::Bib::Address, Relaton::Bib::Contact>]
      # @param logo [Relaton::Bib::Image, nil]
      def initialize(**args)
        @name = args[:name]
        @abbreviation = args[:abbreviation]
        @subdivision  = args[:subdivision] || []
        @identifier = args[:identifier] || []
        @contact = args[:contact] || []
        @logo = args[:logo]
      end

      # @param opts [Hash]
      # @option opts [Nokogiri::XML::Builder] :builder XML builder
      # @option opts [String] :lang language
      # def to_xml(**opts) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
      #   opts[:builder].organization do |builder|
      #     nm = name.select { |n| n.language&.include? opts[:lang] }
      #     nm = name unless nm.any?
      #     nm.each { |n| builder.name { |b| n.to_xml b } }
      #     sbdv = subdivision.select { |sd| sd.language&.include? opts[:lang] }
      #     sbdv = subdivision unless sbdv.any?
      #     sbdv.each { |sd| builder.subdivision { sd.to_xml builder } }
      #     builder.abbreviation { |a| abbreviation.to_xml a } if abbreviation
      #     builder.uri url if uri
      #     identifier.each { |identifier| identifier.to_xml builder }
      #     super builder
      #     builder.logo { |b| logo.to_xml b } if logo
      #   end
      # end

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

      # private

      # @param arg [String, Hash, RelatoBib::LocalizedString]
      # @return [RelatoBib::LocalizedString]
      # def localized_string(arg)
      #   case arg
      #   when String then LocalizedString.new(content: arg)
      #   when Hash then LocalizedString.new(**arg)
      #   when LocalizedString then arg
      #   end
      # end
    end
  end
end
