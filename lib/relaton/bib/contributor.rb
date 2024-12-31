# frozen_string_literal: true

require_relative "person"

module Relaton
  module Bib
    # Contribution info.
    class Contributor
      # Contributor's role.
      class Role
        TYPES = %w[author performer publisher editor adapter translator
                   distributor realizer owner authorizer enabler subject].freeze

        # @return [Array<Relaton::Bib::FormattedString>]
        attr_accessor :description

        # @return [Strig]
        attr_accessor :type

        # @param type [String] allowed types "author", "editor",
        #   "cartographer", "publisher"
        # @param description [Array<LoclizedString>]
        def initialize(**args)
          if args[:type] && !TYPES.include?(args[:type])
            Util.warn %{WARNING: Contributor's type `#{args[:type]}` is invalid.}
          end

          @type = args[:type]
          @description = args.fetch(:description, [])
        end

        # @param opts [Hash]
        # @option opts [Nokogiri::XML::Builder] :builder XML builder
        # @option opts [String] :lang language
        # def to_xml(**opts) # rubocop:disable Metrics/AbcSize
        #   opts[:builder].role(type: type) do |builder|
        #     desc = description.select { |d| d.language&.include? opts[:lang] }
        #     desc = description unless desc.any?
        #     desc.each do |d|
        #       builder.description { |b| d.to_xml(b) }
        #     end
        #   end
        # end

        # @return [Hash, String]
        # def to_hash
        #   hash = {}
        #   hash["description"] = description.map(&:to_hash) if description&.any?
        #   hash["type"] = type if type
        #   hash
        # end

        # @param prefix [String]
        # @param count [Integer] number of contributors
        # 2return [String]
        def to_asciibib(prefix = "", count = 1)
          pref = prefix.empty? ? prefix : "#{prefix}."
          out = count > 1 ? "#{prefix}.role::\n" : ""
          description.each do |d|
            out += d.to_asciibib "#{pref}role.description", description.size
          end
          out += "#{pref}role.type:: #{type}\n" if type
          out
        end
      end

      # @return [Array<Relaton::Bib::Contributor::Role>]
      attr_accessor :role

      # @return [Relaton::Bib::ContributionInfo]
      attr_accessor :entity

      # @param entity [Relaton::Bib::ContributionInfo]
      # @param role [Array<Relaton::Bib::Contributor::Role>]
      def initialize(**args)
        @entity = args[:entity]
        @role   = args[:role] || []
      end

      def person
        entity if entity.is_a? Person
      end

      def person=(person)
        @entity = person if person
      end

      def organization
        entity if entity.is_a? Organization
      end

      def organization=(organization)
        @entity = organization if organization
      end

      # @param opts [Hash]
      # @option opts [Nokogiri::XML::Builder] :builder XML builder
      # @option opts [String, Symbol] :lang language
      # def to_xml(**opts)
      #   entity.to_xml(**opts)
      # end

      # @return [Hash]
      # def to_hash
      #   hash = entity.to_hash
      #   hash["role"] = single_element_array(role) if role&.any?
      #   hash
      # end

      # @param prefix [String]
      # @param count [Integer] number of contributors
      # @return [String]
      def to_asciibib(prefix = "", count = 1)
        pref = prefix.split(".").first
        out = count > 1 ? "#{pref}::\n" : ""
        out += entity.to_asciibib prefix
        role.each { |r| out += r.to_asciibib pref, role.size }
        out
      end
    end
  end
end
