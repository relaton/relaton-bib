module RelatonBib
  module Element
    class Pre < Text
      include ToString

      # @return [String]
      attr_reader :id

      # @return [String, nil]
      attr_reader :alt

      # @return [RelatonBib::Element::Tname, nil]
      attr_reader :tname

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      #
      # Initialize pre element.
      #
      # @param [String] id
      # @param [RelatonBib::Element::Text] content
      # @param [Array<RelatonBib::Element::Note>] note
      # @param [String, nil] alt
      # @param [RelatonBib::Element::Tname, nil] tname
      #
      def initialize(id:, content:, note: [], **args)
        super content
        @id = id
        @alt = args[:alt]
        @tname = args[:tname]
        @note = note
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        node = builder.pre(id: id) do |b|
          tname&.to_xml b
          super b
          note.each { |n| n.to_xml b }
        end
        node[:alt] = alt if alt
      end

      # # @param prefix [String]
      # # @return [String]
      # def to_asciibib(prefix = "")
      #   pref = prefix.empty? ? "pre" : "#{prefix}.pre"
      #   out = "#{pref}.id:: #{id}\n"
      #   out += "#{pref}.alt:: #{alt}\n" if alt
      #   out += tname.to_asciibib("#{pref}.tname") if tname
      #   out += content.to_asciibib "#{pref}."
      #   out
      # end

      # # @return [Hash]
      # def to_hash
      #   hash = { "id" => id }
      #   hash["alt"] = alt if alt
      #   hash["tname"] = tname.to_hash if tname
      #   hash.merge super
      # end
    end
  end
end
