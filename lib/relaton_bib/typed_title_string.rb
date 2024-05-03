module RelatonBib
  class TypedTitleStringCollection
    extend Forwardable

    def_delegators :@array, :[], :first, :last, :empty?, :any?, :size,
                   :each, :detect, :map, :reduce, :length

    # @param title [Array<RelatonBib::TypedTitleString, Hash>]
    def initialize(title = [])
      @array = (title || []).map do |t|
        t.is_a?(Hash) ? TypedTitleString.new(**t) : t
      end
    end

    # @param lang [String, nil] language code Iso639
    # @return [RelatonIsoBib::TypedTitleStringCollection]
    def lang(lang = nil)
      if lang
        TypedTitleStringCollection.new select_lang(lang)
      else self
      end
    end

    def delete_title_part!
      titles.delete_if { |t| t.type == "title-part" }
    end

    # @return [RelatonBib::TypedTitleStringCollection]
    def select(&block)
      TypedTitleStringCollection.new titles.select(&block)
    end

    # @param init [Array, Hash]
    # @return [RelatonBib::TypedTitleStringCollection]
    # def reduce(init)
    #   self.class.new @array.reduce(init) { |m, t| yield m, t }
    # end

    # @param title [RelatonBib::TypedTitleString]
    # @return [self]
    def <<(title)
      titles << title
      self
    end

    # @param tcoll [RelatonBib::TypedTitleStringCollection]
    # @return [RelatonBib::TypedTitleStringCollection]
    def +(tcoll)
      TypedTitleStringCollection.new titles + tcoll.titles
    end

    def titles
      @array
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] XML builder
    # @option opts [String, Symbol] :lang language
    def to_xml(**opts)
      tl = select_lang(opts[:lang])
      tl = titles unless tl.any?
      tl.each { |t| opts[:builder].title { |b| t.to_xml b } }
    end

    def to_h
      @array.map(&:to_h)
    end

    #
    # Add main title ot bibtex entry
    #
    # @param [BibTeX::Entry] item bibtex entry
    #
    def to_bibtex(item)
      tl = titles.detect { |t| t.type == "main" } || titles.first
      return unless tl

      item.title = tl.to_s
    end

    private

    # @param lang [String]
    # @return [Array<RelatonBib::TypedTitleString]
    def select_lang(lang)
      titles.select { |t| t.language.include? lang }
    end
  end

  class TypedTitleString
    include RelatonBib::LocalizedStringAttrs
    include RelatonBib::Element::Base

    # @return [String, nil]
    attr_reader :type

    # @return [Array<RelatonBib::Element::Base, RelatonBib::Element::Text>]
    attr_reader :content

    # @param content [Array<RelatonBib::Element::Base, RelatonBib::Element::Text>, String]
    # @param type [String, nil]
    # @param language [String, nil]
    # @param script [String, nil]
    # @param locale [String, nil]
    def initialize(content:, type: nil, **args)
      @type = type
      super
      @content = content.is_a?(String) ? Element.parse_text_elements(content) : content
    end

    #
    # Create TypedTitleStringCollection from string
    #
    # @param content [String] title string
    # @param lang [String, nil] language code Iso639
    # @param script [String, nil] script code Iso15924
    # @param locale [String, nil]
    #
    # @return [TypedTitleStringCollection] collection of TypedTitleString
    #
    def self.from_string(content, lang: nil, script: nil, locale: nil)
      types = %w[title-intro title-main title-part]
      ttls = split_title(content)
      tts = ttls.map.with_index do |p, i|
        next unless p

        new type: types[i], content: p, language: lang, script: script
      end.compact
      main = tts.map(&:to_s).join " - "
      tts << new(type: "main", content: main, language: lang, script: script, locale: locale)
      TypedTitleStringCollection.new tts
    end

    # @param content [String]
    # @return [Array<String, nil>]
    def self.split_title(content)
      ttls = content.sub(/\w\.Imp\s?\d+\u00A0:\u00A0/, "").split " - "
      case ttls.size
      when 0, 1 then [nil, ttls.first.to_s, nil]
      else intro_or_part ttls
      end
    end

    # @param ttls [Array<String>]
    # @return [Array<String, nil>]
    def self.intro_or_part(ttls)
      if /^(Part|Partie) \d+:/.match? ttls[1]
        [nil, ttls[0], ttls[1..].join(" -- ")]
      else
        parts = ttls.slice(2..-1)
        part = parts.join " -- " if parts.any?
        [ttls[0], ttls[1], part]
      end
    end

    def content=(content)
      @content = content.is_a?(String) ? Element.parse_text_elements(content) : content
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.parent[:type] = type if type
      super
    end

    # @return [Hash]
    def to_h
      hash = { "content" => to_s }
      hash["type"] = type if type
      hash.merge super
    end

    # @param prefix [String]
    # @param count [Integer] number of titles
    # @return [String]
    def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize
      pref = prefix.empty? ? "title" : "#{prefix}.title"
      out = count > 1 ? "#{pref}::\n" : ""
      out += "#{pref}.type:: #{type}\n" if type
      # out += "#{pref}.content:: #{self}\n"
      out += super(pref)
      out
    end

    def to_s
      content.map(&:to_s).join
    end
  end
end
