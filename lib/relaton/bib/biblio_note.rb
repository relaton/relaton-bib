module Relaton
  module Bib
    class BiblioNoteCollection
      extend Forwardable

      def_delegators  :@array, :[], :first, :last, :empty?, :any?, :size,
                      :each, :map, :reduce, :detect, :length

      def initialize(notes)
        @array = notes
      end

      # @param bibnote [Relaton::Bib::BiblioNote]
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

    class BiblioNote # < FormattedString
      # @return [String, nil]
      attr_accessor :type, :language, :script, :locale

      # @return [Relaton::Model::LocalizedMarkedUpString]
      attr_reader :content

      # @param content [String, Relaton::Model::LocalizedStringCollection, nil]
      # @param type [String, nil]
      # @param language [String, nil] language code Iso639
      # @param script [String, nil] script code Iso15924
      # @param locale [String, nil] the content format
      def initialize(**args)
        self.content = args[:content]
        @type = args[:type]
        @language = args[:language]
        @script = args[:script]
        @locale = args[:locale]
      end

      def content=(content)
        @content = content.is_a?(String) ? Relaton::Model::LocalizedString.from_xml(content) : content
      end

      # @param builder [Nokogiri::XML::Builder]
      # def to_xml(builder)
      #   xml = builder.note { super }
      #   xml[:type] = type if type
      #   xml
      # end

      # @return [Hash]
      # def to_hash
      #   hash = super
      #   return hash unless type

      #   hash = { "content" => hash } if hash.is_a? String
      #   hash["type"] = type
      #   hash
      # end

      # @param prefix [String]
      # @param count [Integer] number of notes
      # @return [String]
      def to_asciibib(prefix = "", count = 1)
        pref = prefix.empty? ? prefix : "#{prefix}."
        has_attrs = !(type.nil? || type.empty?)
        out = count > 1 && has_attrs ? "#{pref}biblionote::\n" : ""
        out += "#{pref}biblionote.type:: #{type}\n" if type
        out += super "#{pref}biblionote", 1, has_attrs
        out
      end
    end
  end
end
