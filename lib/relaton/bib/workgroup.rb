module Relaton
  module Bib
    class WorkGroup
      # @return [String]
      attr_accessor :content

      # @return [Integer, nil]
      attr_accessor :number

      # @return [String, nil]
      attr_accessor :identifier, :prefix, :type

      # @param content [String]
      # @param identifier [String, nil]
      # @param prefix [String, nil]
      # @param number [Integer, nil]
      # @param type [String, nil]
      def initialize(content: nil, identifier: nil, prefix: nil, number: nil, type: nil)
        @identifier = identifier
        @prefix = prefix
        @content = content
        @number = number
        @type = type
      end

      # @param builder [Nokogiri::XML::Builder]
      # def to_xml(builder) # rubocop:disable Metrics/AbcSize
      #   builder.text name
      #   builder.parent[:number] = number if number
      #   builder.parent[:type] = type if type
      #   builder.parent[:identifier] = identifier if identifier
      #   builder.parent[:prefix] = prefix if prefix
      # end

      # @return [Hash]
      # def to_hash
      #   hash = { "name" => name }
      #   hash["number"] = number if number
      #   hash["type"] = type if type
      #   hash["identifier"] = identifier if identifier
      #   hash["prefix"] = prefix if prefix
      #   hash
      # end

      # @param prfx [String]
      # @param count [Integer]
      # @return [String]
      def to_asciibib(prfx = "", count = 1) # rubocop:disable Metrics/CyclomaticComplexity
        pref = prfx.empty? ? prfx : "#{prfx}."
        out = count > 1 ? "#{pref}::\n" : ""
        out += "#{pref}content:: #{content}\n"
        out += "#{pref}number:: #{number}\n" if number
        out += "#{pref}type:: #{type}\n" if type
        out += "#{pref}identifier:: #{identifier}\n" if identifier
        out += "#{pref}prefix:: #{prefix}\n" if prefix
        out
      end
    end
  end
end
