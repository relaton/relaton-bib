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

  class BiblioNote
    include LocalizedStringAttrs
    include Element::Base

    # @return [String, nil]
    attr_reader :type

    # @param content [String, Array<RelatonBib::Element::Text, RelatonBib::Element::Base>]
    # @param type [String, nil]
    # @param language [Array<String>] language code Iso639
    # @param script [Array<String>] script code Iso15924
    # @param locale [String, nil] locale code
    def initialize(content:, type: nil, language: [], script: [], locale: nil)
      @type = type
      super
      @content = Element.parse_text_elements(content) if content.is_a? String
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      xml = builder.note { super }
      xml[:type] = type if type
    end

    # @return [Hash]
    def to_h
      hash = super
      return hash unless type

      # hash = { "content" => hash } if hash.is_a? String
      hash["type"] = type
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of notes
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? "biblionote" : "#{prefix}.biblionote"
      # has_attrs = !(type.nil? || type.empty? || language.empty? || script.empty?)
      out = count > 1 ? "#{pref}::\n" : ""
      out += "#{pref}.type:: #{type}\n" if type
      out += super "#{pref}" # , 1, has_attrs
      out
    end
  end
end
