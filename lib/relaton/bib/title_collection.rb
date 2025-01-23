module Relaton
  module Bib
    class TitleCollection
      extend Forwardable

      # @return [Array<Relaton::Bib::Title>]
      attr_accessor :titles

      def_delegators :@titles, :[], :first, :last, :empty?, :any?, :size,
                     :each, :detect, :map, :reduce, :length, :find

      # @param title [Array<Relaton::Bib::Title, Hash>]
      def initialize(titles = [])
        @titles = titles
      end

      #
      # Create TitleCollection from string
      #
      # @param title [String] title string
      # @param lang [String, nil] language code Iso639
      # @param script [String, nil] script code Iso15924
      # @param format [String] format text/html, text/plain
      #
      # @return [Relaton::Bib::TitleCollection] collection of Title
      #
      def self.from_string(title, lang = nil, script = nil, format = "text/plain")
        types = %w[title-intro title-main title-part]
        ttls = split_title(title)
        tts = ttls.map.with_index do |p, i|
          next unless p

          Title.new type: types[i], content: p, language: lang, script: script, format: format
        end.compact
        tts << Title.new(type: "main", content: ttls.compact.join(" - "),
                         language: lang, script: script, format: format)
        new tts
      end

      # @param title [String]
      # @return [Array<String, nil>]
      def self.split_title(title)
        ttls = title.sub(/\w\.Imp\s?\d+\u00A0:\u00A0/, "").split " - "
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

      # @param lang [String, nil] language code Iso639
      # @return [RelatonIsoBib::TitleCollection]
      def lang(lang = nil)
        if lang
          new select_lang(lang)
        else self
        end
      end

      def delete_title_part!
        titles.delete_if { |t| t.type == "title-part" }
      end

      # @return [Relaton::Bib::TitleCollection]
      def select(&block)
        self.class.new titles.select(&block)
      end

      def reject(&block)
        self.class.new titles.reject(&block)
      end

      # @param init [Array, Hash]
      # @return [Relaton::Bib::TitleCollection]
      # def reduce(init)
      #   self.class.new @titles.reduce(init) { |m, t| yield m, t }
      # end

      # @param title [Relaton::Bib::Title]
      # @return [self]
      def <<(title)
        titles << title
        self
      end

      # @param tcoll [Relaton::Bib::TitleCollection]
      # @return [Relaton::Bib::TitleCollection]
      def +(tcoll)
        new titles + tcoll.titles
      end

      # @param opts [Hash]
      # @option opts [Nokogiri::XML::Builder] XML builder
      # @option opts [String, Symbol] :lang language
      def to_xml(**opts)
        tl = select_lang(opts[:lang])
        tl = titles unless tl.any?
        # tl.each { |t| opts[:builder].title { t.to_xml opts[:builder] } }
        tl.map { |t| t.to_xml }.join
      end

      def to_hash
        @titles.map(&:to_hash)
      end

      #
      # Add main title ot bibtex entry
      #
      # @param [BibTeX::Entry] item bibtex entry
      #
      def to_bibtex(item)
        tl = titles.detect { |t| t.type == "main" } || titles.first
        return unless tl

        item.title = tl.content
      end

      # This is needed for lutaml-model to treat TitleCollection instance as Array
      def is_a?(klass)
        klass == Array || super
      end

      private

      # @param lang [String]
      # @return [Array<Relaton::Bib::Title]
      def select_lang(lang)
        return [] unless lang

        titles.select { |t| t.language&.include? lang }
      end
    end
  end
end
