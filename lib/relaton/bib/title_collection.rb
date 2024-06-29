module Relaton
  module Bib
    class TitleCollection
      extend Forwardable

      # @return [Array<Relaton::Bib::Title>]
      attr_accessor :titles

      def_delegators :@titles, :[], :first, :last, :empty?, :any?, :size,
                     :each, :detect, :map, :reduce, :length

      # @param title [Array<Relaton::Bib::Title, Hash>]
      def initialize
        @titles = []
      #   @titles = (title || []).map do |t|
      #     t.is_a?(Hash) ? Title.new(**t) : t
      #   end
      end

      def self.cast(value)
        value
      end

      # @param lang [String, nil] language code Iso639
      # @return [RelatonIsoBib::TitleCollection]
      def lang(lang = nil)
        if lang
          TitleCollection.new select_lang(lang)
        else self
        end
      end

      def delete_title_part!
        titles.delete_if { |t| t.type == "title-part" }
      end

      # @return [Relaton::Bib::TitleCollection]
      def select(&block)
        TitleCollection.new titles.select(&block)
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
        TitleCollection.new titles + tcoll.titles
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

        item.title = tl.title.content
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
