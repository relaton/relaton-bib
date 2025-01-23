# frozen_string_literal: true

module Relaton
  module Bib
    # Localized string.
    class LocalizedString < LocalizedStringAttrs
      # @return [String]
      attr_accessor :content

      # @param content [String, Relaton::Bib::LocalizedString::Variants]
      # @param language [String, nil] language code Iso639
      # @param script [String, nil] script code Iso15924
      # @param locale [String, nil] language and script code
      def initialize(**args)
        super
        @content = args[:content]
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
    end
  end
end
