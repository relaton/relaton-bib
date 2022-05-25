module RelatonBib
  class BibliographicSize
    extend Forwardable

    def_delegators :@size, :any?

    # @return [Array<RelatonBib::BibliographicSize::Value>]
    attr_reader :size

    #
    # Initialize a BibliographicSize object.
    #
    # @param [<Type>] size <description>
    #
    def initialize(size)
      @size = size
    end

    #
    # Render BibliographicSize object to XML.
    #
    # @param [Nokogiri::XML::Builder] builder the XML builder
    #
    def to_xml(builder)
      return if size.empty?

      builder.size do
        size.each { |s| s.to_xml builder }
      end
    end

    #
    # Render BibliographicSize object to AsciiBib.
    #
    # @param [String] prefix prefix for the size
    #
    # @return [String] AsciiBib string
    #
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? "size" : "#{prefix}.size"
      size.map { |s| s.to_asciibib pref, size.size }.join
    end

    #
    # Render BibliographicSize object to hash.
    #
    # @return [<Type>] <description>
    #
    def to_hash
      size.map &:to_hash
    end

    class Value
      # @return [String]
      attr_reader :type, :value

      #
      # Initialize a BibliographicSize::Value object.
      #
      # @param [String] type the type of the size
      # @param [String] value size value
      #
      def initialize(type:, value:)
        @type = type
        @value = value
      end

      #
      # Render BibliographicSize::Value object to XML.
      #
      # @param [Nokogiri::XML::Builder] builder the XML builder
      #
      def to_xml(builder)
        builder.value value, type: type
      end

      #
      # Render BibliographicSize::Value object to hash.
      #
      # @return [<Type>] <description>
      #
      def to_hash
        { type: type, value: value }
      end

      #
      # Render BibliographicSize::Value object to AsciiBib.
      #
      # @param [String] prefix prefix for the size
      # @param [Integer] size size of the array
      #
      # @return [String] AsciiBib string
      #
      def to_asciibib(prefix, size)
        pref = prefix.empty? ? "" : "#{prefix}."
        out = ""
        out << "#{prefix}::\n" if size.size > 1
        out << "#{pref}type:: #{type}\n"
        out << "#{pref}value:: #{value}\n"
      end
    end
  end
end
