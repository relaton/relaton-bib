module RelatonBib
  class Forename < LocalizedString
    # @return [String, nil]
    attr_accessor :initial

    #
    # Initialize Forename instance
    #
    # @param [String] content content of forename, can be empty
    # @param [Array<String>] language languages, `en`, `fr`, `de` etc.
    # @param [Array<String>] script scripts `Latn`, `Cyrl` etc.
    # @param [String, nil] initial initial of forename
    #
    def initialize(content: nil, language: [], script: [], initial: nil)
      @initial = initial
      super content, language, script
    end

    def ==(other)
      super && initial == other.initial
    end

    def to_s
      content.nil? ? initial : super
    end

    #
    # Render forename to XML
    #
    # @param [Nokogiri::XML::Builder] builder XML builder
    #
    def to_xml(builder)
      node = builder.forename { super }
      node[:initial] = initial if initial
    end

    #
    # Render forename to hash
    #
    # @return [Hash, String] forename hash or string representation
    #
    def to_hash
      ls = super
      hash = ls.is_a?(Hash) ? ls : { "content" => ls }
      hash["initial"] = initial if initial
      hash
    end

    #
    # Render forename to asciibib
    #
    # @param [String] pref prefix
    # @param [Integer] count size of array
    #
    # @return [String] asciibib string
    #
    def to_asciibib(pref, count = 1)
      prf = pref.empty? ? pref : "#{pref}."
      prf += "forename"
      out = super prf, count
      out += "#{prf}.initial:: #{initial}\n" if initial
      out
    end
  end
end
