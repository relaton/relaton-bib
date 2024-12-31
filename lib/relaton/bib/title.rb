module Relaton
  module Bib
    class Title < Relaton::Bib::LocalizedString
      ARGS = %i[type content format].freeze # @DEPRECATED format
      ARGS.each { |a| attr_accessor a }

      # @param type [String]
      # @param content [String]
      # @param language [String]
      # @param script [String]
      # @param locale [String]
      def initialize(**args)
        ARGS.each { |a| instance_variable_set "@#{a}", args[a] }
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
        out += "#{pref}title.content:: #{content}\n"
        out
      end
    end
  end
end
