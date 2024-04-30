module RelatonBib
  module Element
    class Pre
      include Base
      include ToString

      # @return [String]
      attr_reader :id

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Text, RelatonBib::Element::Note>]

      # @return [String, nil]
      attr_reader :alt

      # @return [RelatonBib::Element::Tname, nil]
      attr_reader :tname

      #
      # Initialize pre element.
      #
      # @param [String] id
      # @param [Array<RelatonBib::Element::Text, RelatonBib::Element::Note>] content
      # @param [String, nil] alt
      # @param [RelatonBib::Element::Tname, nil] tname
      #
      def initialize(id:, content:, **args)
        @content = content
        @id = id
        @alt = args[:alt]
        @tname = args[:tname]
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        node = builder.pre(id: id) do |b|
          tname&.to_xml b
          super b
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
