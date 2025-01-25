module Relaton
  module Bib
    # Affiliation.
    class Affiliation
      # include Relaton

      # @return [Relaton::Bib::LocalizedString, nil]
      attr_accessor :name

      attr_writer :description

      # @return [Relaton::Bib::Organization]
      attr_accessor :organization

      # @param organization [Relaton::Bib::Organization, nil]
      # @param name [Relaton::Bib::LocalizedString, nil]
      # @param description [Array<Relaton::Bib::LocalizedString>]
      def initialize(organization: nil, name: nil, description: [])
        @name = name
        @organization = organization
        @description  = description
      end

      def ==(other)
        name == other.name && organization == other.organization &&
          description == other.description
      end

      # @param opts [Hash]
      # @option opts [Nokogiri::XML::Builder] :builder XML builder
      # @option opts [String] :lang language
      # def to_xml(**opts)
      #   return unless organization || name || description&.any?

      #   opts[:builder].affiliation do |builder|
      #     name_xml builder
      #     description_xml builder
      #     organization&.to_xml(**opts)
      #   end
      # end

      # def name_xml(builder)
      #   builder.name { name.to_xml builder } if name
      # end

      # def description_xml(builder)
      #   description.each { |d| builder.description { d.to_xml builder } }
      # end

      #
      # Get description.
      #
      # @param [String, nil] lang language if nil return all description
      #
      # @return [Array<Relaton::Bibb::FormattedString>] description
      #
      def description(lang = nil)
        return @description unless lang

        @description.select { |d| d.language&.include? lang }
      end

      #
      # Render affiliation as hash.
      #
      # @return [Hash]
      #
      # def to_hash
      #   hash = organization&.to_hash || {}
      #   hash["name"] = name.to_hash if name
      #   if description&.any?
      #     hash["description"] = single_element_array(description)
      #   end
      #   hash
      # end

      # @param prefix [String]
      # @param count [Integer]
      # @return [String]
      def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize
        pref = prefix.empty? ? prefix : "#{prefix}."
        out = count > 1 ? "#{pref}affiliation::\n" : ""
        out += name.to_asciibib "#{pref}affiliation.name" if name
        description.each do |d|
          out += d.to_asciibib "#{pref}affiliation.description", description.size
        end
        out += organization.to_asciibib "#{pref}affiliation.*" if organization
        out
      end
    end
  end
end
