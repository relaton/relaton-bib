# frozen_string_literal: true

module Relaton
  module Bib
    # Person identifier type.
    # module PersonIdentifierType
    #   ISNI  = "isni"
    #   ORCID = "orcid"
    #   URI   = "uri"

    #   # Checks type.
    #   # @param type [String]
    #   # @raise [ArgumentError] if type isn't "isni" or "uri"
    #   def self.check(type)
    #     unless [ISNI, ORCID, URI].include? type
    #       raise ArgumentError, 'Invalid type. It should be "isni", "orcid", "\
    #         "or "uri".'
    #     end
    #   end
    # end

    # Person class.
    class Person
      # Person identifier.
      class Identifier
        # @return [Relaton::Bib::PersonIdentifierType::ISNI,
        #   Relaton::Bib::PersonIdentifierType::ORCID,
        #   Relaton::Bib::PersonIdentifierType::URI]
        attr_accessor :type

        # @return [String]
        attr_accessor :content

        # @param type [Relaton::Bib::PersonIdentifierType::ISNI,
        #   Relaton::Bib::PersonIdentifierType::ORCID,
        #   Relaton::Bib::PersonIdentifierType::URI]
        # @param conten [String]
        def initialize(**args)
          # PersonIdentifierType.check type

          @type     = args[:type]
          @content  = args[:content]
        end

        # @param builser [Nokogiri::XML::Builder]
        def to_xml(builder)
          builder.identifier conten, type: type
        end

        # @return [Hash]
        def to_hash
          { "type" => type, "id" => conten }
        end

        # @param prefix [String]
        # @param count [Integer] number of ids
        # @return [String]
        def to_asciibib(prefix = "", count = 1)
          pref = prefix.empty? ? prefix : "#{prefix}."
          out = count > 1 ? "#{prefix}::\n" : ""
          out += "#{pref}type:: #{type}\n"
          out += "#{pref}conten:: #{conten}\n"
          out
        end
      end

      # @return [Relaton::Bib::FullName]
      attr_accessor :name

      # @return [Array<String>]
      attr_accessor :credential

      # @return [Array<Relaton::Bib::Affiliation>]
      attr_accessor :affiliation

      # @return [Array<Relaton::Bib::Person::Identifier>]
      attr_accessor :identifier

      attr_accessor :address, :phone, :email, :uri

      # @param name [Relaton::Bib::FullName]
      # @param credential [Array<String>]
      # @param affiliation [Array<Relaton::Bib::Affiliation>]
      # @param identifier [Array<Relaton::Bib::Person::Identifier>]
      # @param address [Array<Relaton::Bib::Address]
      # @param phone [Array<Relaton::Bib::Phone]
      # @param email [Array<String>]
      # @param uri [Array<Relaton::Bib::Uri]
      def initialize(**args) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        @name         = args[:name]
        @credential   = args[:credential] || []
        @affiliation  = args[:affiliation] || []
        @identifier   = args[:identifier] || []
        @address      = args[:address] || []
        @phone        = args[:phone] || []
        @email        = args[:email] || []
        @uri          = args[:uri] || []
      end

      # @param opts [Hash]
      # @option opts [Nokogiri::XML::Builder] :builder XML builder
      # @option opts [String, Symbol] :lang language
      # def to_xml(**opts) # rubocop:disable Metrics/AbcSize
      #   opts[:builder].person do |builder|
      #     name.to_xml(**opts)
      #     credential.each { |c| builder.credential c }
      #     affiliation.each { |a| a.to_xml(**opts) }
      #     identifier.each { |id| id.to_xml builder }
      #     contact.each { |contact| contact.to_xml builder }
      #   end
      # end

      # @return [Hash]
      # def to_hash # rubocop:disable Metrics/AbcSize
      #   hash = { "name" => name.to_hash }
      #   hash["credential"] = credential if credential.any?
      #   hash["affiliation"] = affiliation.map &:to_hash if affiliation.any?
      #   hash["identifier"] = identifier.map &:to_hash if identifier.any?
      #   { "person" => hash.merge(super) }
      # end

      # @param prefix [String]
      # @count [Integer] number of persons
      # @return [String]
      def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize
        pref = prefix.sub(/\*$/, "person")
        out = count > 1 ? "#{pref}::\n" : ""
        out += name.to_asciibib pref
        credential.each { |c| out += "#{pref}.credential:: #{c}\n" }
        affiliation.each { |af| out += af.to_asciibib pref, affiliation.size }
        identifier.each { |id| out += id.to_asciibib pref, identifier.size }
        out += super pref
        out
      end
    end
  end
end
