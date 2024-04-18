# frozen_string_literal: true

require "relaton_bib/person"

# RelatonBib module
module RelatonBib
  # Contribution info.
  class ContributionInfo
    # Contributor's role.
    class Role
      class Description
        include LocalizedStringAttrs
        include Element::Base

        def initialize(content:, **args)
          super
          @content = content.is_a?(String) ? Element.parse_pure_text_elements(content) : content
        end

        def to_xml(builder)
          builder.description do |b|
            # Element::Base.instance_method(:to_xml).bind_call(self, b)
            super b
          end
        end

        def to_h
          hash = super
          hash["language"] = language if language.any?
          hash["script"] = script if script.any?
          hash["locale"] = locale if locale
          hash
        end

        def to_asciibib(prefix = "", count = 1)
          pref = prefix.empty? ? "description" : "#{prefix}.description"
          out = count > 1 ? "#{prefix}::\n" : ""
          # out += "#{pref}.content:: #{self}\n"
          out + super(pref)
        end
      end

      TYPES = %w[author performer publisher editor adapter translator
                distributor realizer owner authorizer enabler subject].freeze

      # @return [Array<RelatonBib::FormattedString>]
      attr_reader :description

      # @return [Strig]
      attr_reader :type

      # @param type [String] allowed types author, editor, cartographer, publisher
      # @param description [Array<RelatonBib::ContributionInfo::Role::Description>]
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
      def to_xml(**opts) # rubocop:disable Metrics/AbcSize
        opts[:builder].role(type: type) do |builder|
          desc = description.select { |d| d.language.include? opts[:lang] }
          desc = description unless desc.any?
          desc.each { |d| d.to_xml(builder) }
        end
      end

      # @return [Hash, String]
      def to_hash
        hash = {}
        hash["description"] = description.map(&:to_h) if description&.any?
        hash["type"] = type if type
        hash
      end

      # @param prefix [String]
      # @param count [Integer] number of contributors
      # 2return [String]
      def to_asciibib(prefix = "", count = 1)
        pref = prefix.empty? ? "role" : "#{prefix}.role"
        out = count > 1 ? "#{pref}::\n" : ""
        description.each do |d|
          out += d.to_asciibib pref, description.size
        end
        out += "#{pref}.type:: #{type}\n" if type
        out
      end
    end

    # @return [Array<RelatonBib::ContributionInfo::Role>]
    attr_reader :role

    # @return [RelatonBib::Person, RelatonBib::Organization]
    attr_reader :entity

    # @param entity [RelatonBib::Person, RelatonBib::Organization]
    # @param role [Array<Hash>]
    # @option role [String] :type
    # @option role [Array<String>] :description
    def initialize(entity:, role: [])
      if role.empty?
        role << { type: entity.is_a?(Person) ? "author" : "publisher" }
      end
      @entity = entity
      @role   = role.map { |r| Role.new(**r) }
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String, Symbol] :lang language
    def to_xml(**opts)
      entity.to_xml(**opts)
    end

    # @return [Hash]
    def to_hash
      hash = entity.to_hash
      hash["role"] = role.map(&:to_hash) if role&.any?
      hash
    end

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
