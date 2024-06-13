module RelatonBib
  module Element
    class Table
      class Note
        # @return [RelatonBib::Element::Paragraph]
        attr_reader :content

        #
        # Initialize a new table note element.
        #
        # @param [RelatonBib::Element::Paragraph] content
        #
        def initialize(content)
          @content = content
        end

        def to_xml(builder)
          builder.note { |b| content.to_xml b }
        end
      end

      # @return [String]
      attr_reader :id

      # @return [Boolean, nil]
      attr_reader :unnumbered

      # @return [String, nil]
      attr_reader :subsequence, :alt, :summary, :uri

      # @return [RelatonBib::Element::Tname, nil]
      attr_reader :tname

      # @return [RelatonBib::Element::Thead, nil]
      attr_reader :thead

      # @return [RelatonBib::Element::Tbody]
      attr_reader :tbody

      # @return [RelatonBib::Element::Tfoot, nil]
      attr_reader :tfoot

      # @return [Array<RelatonBib::Element::Table::Note>]
      attr_reader :note

      # @return [RelatonBib::Element::Dl, nil]
      attr_reader :dl

      #
      # Initialize a new table element.
      #
      # @param [String] id <description>
      # @param [RelatonBib::Element::Tbody] tbody
      # @param [Boolean, nil] unnumbered
      # @param [String, nil] subsequence
      # @param [String, nil] alt
      # @param [String, nil] summary
      # @param [String, nil] uri
      # @param [RelatonBib::Element::Tname, nil] tname
      # @param [RelatonBib::Element::Thead, nil] thead
      # @param [RelatonBib::Element::Tfoot, nil] tfoot
      # @param [Array<RelatonBib::Element::Table::Note>] note
      # @param [RelatonBib::Element::Dl, nil] dl
      #
      def initialize(id:, tbody:, **args)
        @id = id
        @unnumbered = args[:unnumbered]
        @subsequence = args[:subsequence]
        @alt = args[:alt]
        @summary = args[:summary]
        @uri = args[:uri]
        @tname = args[:tname]
        @thead = args[:thead]
        @tbody = tbody
        @tfoot = args[:tfoot]
        @note = args[:note] || []
        @dl = args[:dl]
      end

      def to_xml(builder)
        node = builder.table(id: id) do
          tname&.to_xml builder
          thead&.to_xml builder
          tbody&.to_xml builder
          tfoot&.to_xml builder
          note.each { |n| n.to_xml builder }
          dl&.to_xml builder
        end
        node["unnumbered"] = unnumbered unless unnumbered.nil?
        node["subsequence"] = subsequence if subsequence
        node["alt"] = alt if alt
        node["summary"] = summary if summary
        node["uri"] = uri if uri
      end
    end
  end
end
