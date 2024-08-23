# frozen_string_literal: true

module Relaton
  module Bib
    # Localized string.
    class LocalizedString
      # @return [String, nil]
      attr_accessor :language, :script, :locale

      # @return [String]
      attr_accessor :content

      # @param content [String]
      # @param language [String, nil] language code Iso639
      # @param script [String, nil] script code Iso15924
      # @param locale [String, nil] language and script code
      def initialize(**args)
        @content = args[:content]
        @language = args[:language]
        @script = args[:script]
        @locale = args[:locale]
      end

      def ==(other)
        return false unless other.is_a? LocalizedString

        content == other.content && language == other.language && script == other.script
      end

      #
      # String representation.
      #
      # @return [String]
      #
      def to_s
        content
      end

      #
      # Returns true if content is empty.
      #
      # @return [Boolean]
      #
      def empty?
        content.empty?
      end

      #
      # Encode content.
      #
      # @param [String] cnt content
      #
      # @return [String] encoded content
      #
      # def encode(cnt)
      #   escp cnt
      # end

      #
      # Escope HTML entities.
      #
      # @param [String] str input string
      #
      # @return [String] output string
      #
      # def escp(str)
      #   return unless str

      #   coder = HTMLEntities.new
      #   coder.encode coder.decode(str.dup.force_encoding("UTF-8"))
      # end

      # @param prefix [String]
      # @param count [Integer] number of elements
      # @return [String]
      def to_asciibib(prefix = "", count = 1, has_attrs = false)
        pref = prefix.empty? ? prefix : "#{prefix}."
        return "#{prefix}:: #{content}\n" unless language || script || has_attrs

        out = count > 1 ? "#{prefix}::\n" : ""
        out += "#{pref}content:: #{content}\n"
        out += "#{pref}language:: #{language}\n" if language
        out += "#{pref}script:: #{script}\n" if script
        out += "#{pref}locale:: #{locale}\n" if locale
        out
      end

      #
      # Should be implemented in subclass.
      #
      # @param [String] str content
      #
      # @return [String] cleaned content
      #
      # def cleanup(str)
      #   str
      # end
    end
  end
end
