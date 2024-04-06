module RelatonBib
  # Affiliation.
  class Affiliation
    class Description
      include RelatonBib::Element::Base
      include RelatonBib::LocalizedStringAttrs

      def initialize(content:, **args)
        @content = content.is_a?(String) ? Element.parse_text_elements(content) : content
        super(**args)
      end

      def to_xml(builder)
        builder.description do |b|
          Element::Base.instance_method(:to_xml).bind_call(self, b)
          super b
        end
      end

      def to_hash
        hash = { "content" => to_s }
        hash.merge super
      end

      def to_asciibib(prefix = "", count = 1)
        pref = prefix.empty? ? "description" : "#{prefix}.description"
        out = count > 1 ? "#{pref}::\n" : ""
        out += "#{pref}.content:: #{self}\n"
        out += super(pref)
        out
      end
    end

    # @return [RelatonBib::LocalizedString, nil]
    attr_reader :name

    # @return [RelatonBib::Organization]
    attr_reader :organization

    # @param organization [RelatonBib::Organization, nil]
    # @param name [RelatonBib::LocalizedString, nil]
    # @param description [Array<RelatonBib::Affiliation::Description>]
    def initialize(organization: nil, name: nil, description: [])
      @name = name
      @organization = organization
      @description  = description
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String] :lang language
    def to_xml(**opts)
      return unless organization || name || description&.any?

      opts[:builder].affiliation do |builder|
        name_xml builder
        description_xml builder
        organization&.to_xml(**opts)
      end
    end

    def name_xml(builder)
      builder.name { name.to_xml builder } if name
    end

    def description_xml(builder)
      description.each { |d| d.to_xml builder }
    end

    #
    # Get description.
    #
    # @param [String, nil] lang language if nil return all description
    #
    # @return return [Array<RelatonBib::FormattedString>] description
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
    def to_hash
      hash = organization&.to_hash || {}
      hash["name"] = name.to_hash if name
      hash["description"] = description.map(&:to_hash) if description.any?
      hash
    end

    # @param prefix [String]
    # @param count [Integer]
    # @return [String]
    def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize
      pref = prefix.empty? ? "affiliation" : "#{prefix}.affiliation"
      out = count > 1 ? "#{pref}affiliation::\n" : ""
      out += name.to_asciibib "#{pref}.name" if name
      description.each do |d|
        out += d.to_asciibib pref, description.size
      end
      out += organization.to_asciibib pref if organization
      out
    end
  end
end
