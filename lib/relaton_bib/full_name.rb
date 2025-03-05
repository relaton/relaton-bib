module RelatonBib
  # Person's full name
  class FullName
    include RelatonBib

    # @return [Array<RelatonBib::Forename>]
    attr_accessor :forename

    # @return [Array<RelatonBib::LocalizedString>]
    attr_accessor :initials, :addition, :prefix

    # @return [RelatonBib::LocalizedString, nil]
    attr_accessor :surname, :abbreviation, :completename

    #
    # Initialize FullName instance
    #
    # @param surname [RelatonBib::LocalizedString, nil] surname or completename should be present
    # @param abbreviation [RelatonBib::LocalizedString, nil] abbreviation
    # @param forename [Array<RelatonBib::Forename>] forename
    # @param initials [RelatonBib::LocalizedString, String, nil] string of initials
    # @param addition [Array<RelatonBib::LocalizedString>] array of additions
    # @param prefix [Array<RelatonBib::LocalizedString>] array of prefixes
    # @param completename [RelatonBib::LocalizedString, nil] completename or surname should be present
    #
    def initialize(**args) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
      unless args[:surname] || args[:completename]
        raise ArgumentError, "Should be given :surname or :completename"
      end

      @surname      = args[:surname]
      @abbreviation = args[:abbreviation]
      @forename     = args[:forename] || []
      @initials     = args[:initials].is_a?(String) ? LocalizedString.new(args[:initials]) : args[:initials]
      @addition     = args[:addition] || []
      @prefix       = args[:prefix] || []
      @completename = args[:completename]
    end

    def ==(other) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
      surname == other.surname && abbreviation == other.abbreviation &&
        completename == other.completename && forename == other.forename &&
        initials == other.initials && addition == other.addition &&
        prefix == other.prefix
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String] :lang language
    def to_xml(**opts) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      opts[:builder].name do |builder|
        builder.abbreviation { abbreviation.to_xml builder } if abbreviation
        if completename
          builder.completename { completename.to_xml builder }
        else
          pref = prefix.select { |p| p.language&.include? opts[:lang] }
          pref = prefix unless pref.any?
          pref.each { |p| builder.prefix { p.to_xml builder } }
          frnm = forename.select { |f| f.language&.include? opts[:lang] }
          frnm = forename unless frnm.any?
          frnm.each { |f| f.to_xml builder }
          builder.send(:"formatted-initials") { initials.to_xml builder } if initials
          builder.surname { surname.to_xml builder }
          addn = addition.select { |a| a.language&.include? opts[:lang] }
          addn = addition unless addn.any?
          addn.each { |a| builder.addition { a.to_xml builder } }
        end
      end
    end

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
      hash = {}
      hash["abbreviation"] = abbreviation.to_hash if abbreviation
      if forename.any? || initials
        hash["given"] = {}
        hash["given"]["forename"] = single_element_array(forename) if forename&.any?
        hash["given"]["formatted_initials"] = initials.to_hash if initials
      end
      hash["surname"] = surname.to_hash if surname
      hash["addition"] = single_element_array(addition) if addition&.any?
      hash["prefix"] = single_element_array(prefix) if prefix&.any?
      hash["completename"] = completename.to_hash if completename
      hash
    end

    # @param pref [String]
    # @return [String]
    def to_asciibib(pref) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      prf = pref.empty? ? pref : "#{pref}."
      prf += "name"
      out = ""
      out += abbreviation.to_asciibib "#{prf}.abbreviation" if abbreviation
      given = "#{pref}.given"
      out += forename.map do |fn|
        fn.to_asciibib given, forename.size
      end.join
      out += initials.to_asciibib "#{given}.formatted-initials" if initials
      out += surname.to_asciibib "#{prf}.surname" if surname
      addition.each do |ad|
        out += ad.to_asciibib "#{prf}.addition", addition.size
      end
      prefix.each { |pr| out += pr.to_asciibib "#{prf}.prefix", prefix.size }
      out += completename.to_asciibib "#{prf}.completename" if completename
      out
    end
  end
end
