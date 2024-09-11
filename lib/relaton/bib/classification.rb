module Relaton
  module Bib
    class Classification < Relaton::Bib::DocidentifierType
      # # @return [String, nil]
      # attr_accessor :type

      # # @return [String]
      # attr_accessor :value

      # # @param type [String, nil]
      # # @param value [String]
      # def initialize(value:, type: nil)
      #   @type  = type
      #   @value = value
      # end

      # @param builder [Nokogiri::XML::Builder]
      # def to_xml(builder)
      #   xml = builder.classification value
      #   xml[:type] = type if type
      # end

      # @return [Hash]
      # def to_hash
      #   hash = { "value" => value }
      #   hash["type"] = type if type
      #   hash
      # end

      # @param prefix [String]
      # @param count [Integer] number of classifications
      # @return [String]
      def to_asciibib(prefix = "", count = 1)
        pref = prefix.empty? ? "classification" : "#{prefix}.classification"
        out = count > 1 ? "#{pref}::\n" : ""
        out += "#{pref}.type:: #{type}\n" if type
        out += "#{pref}.value:: #{value}\n"
        out
      end
    end
  end
end
