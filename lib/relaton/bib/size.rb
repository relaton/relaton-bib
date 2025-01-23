module Relaton
  module Bib
    class Size
      extend Forwardable

      def_delegators :@value, :any?

      # @return [Array<Relaton::Bib::Size::Value>]
      attr_accessor :value

      #
      # Initialize a Relaton::Bib::Size object.
      #
      # @param [<Relaton::Bib::Size::Value>] value
      #
      def initialize(value = [])
        @value = value
      end

      #
      # Render BibliographicSize object to XML.
      #
      # @param [Nokogiri::XML::Builder] builder the XML builder
      #
      # def to_xml(builder)
      #   return if size.empty?

      #   builder.size do
      #     size.each { |s| s.to_xml builder }
      #   end
      # end

      #
      # Render Relaton::Bib::Size object to AsciiBib.
      #
      # @param [String] prefix prefix for the size
      #
      # @return [String] AsciiBib string
      #
      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "size" : "#{prefix}.size"
        size.map { |s| s.to_asciibib pref, value.size }.join
      end

      #
      # Render BibliographicSize object to hash.
      #
      # @return [<Type>] <description>
      #
      # def to_hash
      #   size.map &:to_hash
      # end

      class Value
        # @return [String]
        attr_accessor :type

        # @return [String, nil]
        attr_accessor :content

        #
        # Bibliographic size value.
        #
        # @param [String] type Recommended values: page, volume, time (in ISO 8601 duration values)
        # @param [String, nil] content The quantity of the size
        #
        def initialize(**args)
          @type = args[:type]
          @content = args[:content]
        end

        #
        # Render BibliographicSize::Value object to XML.
        #
        # @param [Nokogiri::XML::Builder] builder the XML builder
        #
        # def to_xml(builder)
        #   builder.value value, type: type
        # end

        #
        # Render BibliographicSize::Value object to hash.
        #
        # @return [Hash]
        #
        # def to_hash
        #   { type: type, value: value }
        # end

        #
        # Render Relaton::Bib::Size::Value object to AsciiBib.
        #
        # @param [String] prefix prefix for the size
        # @param [Integer] size size of the array
        #
        # @return [String] AsciiBib string
        #
        def to_asciibib(prefix, size)
          pref = prefix.empty? ? "" : "#{prefix}."
          out = ""
          out << "#{prefix}::\n" if size > 1
          out << "#{pref}type:: #{type}\n"
          out << "#{pref}value:: #{content}\n" if content
        end
      end
    end
  end
end
