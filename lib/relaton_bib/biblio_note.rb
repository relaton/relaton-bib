module RelatonBib
  class BiblioNoteCollection
    extend Forwardable

    def_delegators :@array, :[], :first, :last, :empty?, :any?, :size,
                   :each, :map, :reduce, :detect, :length

    def initialize(notes)
      @array = notes
    end

    # @param bibnote [RelatonBib::BiblioNote]
    # @return [self]
    def <<(bibnote)
      @array << bibnote
      self
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] XML builder
    # @option opts [String] :lang language
    def to_xml(**opts)
      bnc = @array.select { |bn| bn.language&.include? opts[:lang] }
      bnc = @array unless bnc.any?
      bnc.each { |bn| bn.to_xml opts[:builder] }
    end
  end

  class BiblioNote < FormattedString
    # @return [String, nil]
    attr_reader :type

    # @param content [String]
    # @param type [String, nil]
    # @param language [String, nil] language code Iso639
    # @param script [String, nil] script code Iso15924
    # @param format [String, nil] the content format
    def initialize(content:, type: nil, language: nil, script: nil, format: nil)
      @type = type
      super content: content, language: language, script: script, format: format
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      xml = builder.note { super }
      xml[:type] = type if type
      xml
    end

    # @return [Hash]
    def to_hash
      hash = super
      return hash unless type

      hash = { "content" => hash } if hash.is_a? String
      hash["type"] = type
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of notes
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : prefix + "."
      has_attrs = !(type.nil? || type.empty?)
      out = count > 1 && has_attrs ? "#{pref}biblionote::\n" : ""
      out += "#{pref}biblionote.type:: #{type}\n" if type
      out += super "#{pref}biblionote", 1, has_attrs
      out
    end
  end
end
