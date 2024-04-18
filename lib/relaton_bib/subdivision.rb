module RelatonBib
  #
  # Subdivision contains organization and type.
  #
  class Subdivision
    # @return [RelatonBib::OrganizationType]
    attr_reader :organization

    # @return [String, nil]
    attr_reader :type

    #
    # Initialize new instance of Subdivision
    #
    # @param [RelatonBib::OrganizationType] organization
    # @param [String, nil] type type of subdivision
    #
    def initialize(organization:, type: nil)
      @organization = organization
      @type = type
    end

    def to_xml(**opts)
      node = opts[:builder].subdivision do
        organization.to_xml(**opts)
      end
      node[:type] = type if type
    end

    def to_h
      hash = organization.to_h
      hash["type"] = type if type
      hash
    end

    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? "subdivision" : "#{prefix}.subdivision"
      out = count > 1 ? "#{pref}::\n" : ""
      out += organization.to_asciibib(pref)
      out += "#{pref}.type:: #{type}\n" if type
      out
    end
  end
end
