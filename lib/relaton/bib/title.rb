module Relaton
  module Bib
    class Title < Relaton::Bib::LocalizedString
      # ARGS = %i[content language script format].freeze

      # @return [String]
      attr_accessor :type # , :language, :script, :locale

      # @param type [Relaton::Model::LocalizedMarkedUpString::Content]
      attr_reader :content

      # @param type [String]
      # @param content [String]
      # @param language [String]
      # @param script [String]
      # @param locale [String]
      def initialize(**args)
        @type = args[:type]
        super
      end

      # @param builder [Nokogiri::XML::Builder]
      # def to_xml
      #   Model::Title.to_xml self
      # end

      # @return [Hash]
      # def to_hash
      #   th = title.to_hash
      #   return th unless type

      #   th.merge "type" => type
      # end

      # @param prefix [String]
      # @param count [Integer] number of titles
      # @return [String]
      def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize
        pref = prefix.empty? ? prefix : "#{prefix}."
        out = count > 1 ? "#{pref}title::\n" : ""
        out += "#{pref}title.type:: #{type}\n" if type
        out += title.to_asciibib "#{pref}title", 1, !(type.nil? || type.empty?)
        out
      end
    end
  end
end
