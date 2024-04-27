module RelatonBib
  module Element
    class AmendType
      class Location
        include Base

        # @!attribute [r] content
        #   @return [Array<RelatonBib::Locality, RelatonBib::LocalityStack>]

        def to_xml(builder)
          builder.location { |b| super b }
        end
      end

      class Description
        include Base

        # @!attribute [r] content BasicBlock
        #  @return [Array<RelatonBib::Element::Base>]

        def to_xml(builder)
          builder.description { |b| super b }
        end
      end

      class Newcontent
        include Base

        # @!attribute [r] content BasicBlock
        #  @return [Array<RelatonBib::Element::Base>]

        # @return [String, nil]
        attr_reader :id

        #
        # Initializes newcontent element.
        #
        # @param [Array<RelatonBib::Element::Base>] content BasicBlock
        # @param [<Type>] id <description>
        #
        def initialize(content:, id: nil)
          super content: content
          @id = id
        end

        def to_xml(builder)
          node = builder.newcontent { |b| super b }
          node["id"] = id if id
        end
      end

      CHANGE = %w[add modify delete replace].freeze

      # @return [String]
      attr_reader :change

      # @return [Array<RelatonBib::Element::Classification>]
      attr_reader :classification

      # @return [Array<RelatonBib::Contributor>]
      attr_reader :contributor

      # @return [String, nil]
      attr_reader :id, :path, :path_end, :title

      # @return [RelatonBib::T::AmendType::Location, nil]
      attr_reader :location

      # @return [RelatonBib::Element::AmendType::Description, nil]
      attr_reader :description

      # @return [RelatonBib::Element::AmendType::Newcontent, nil]
      attr_reader :newcontent

      #
      # Initializes amendment element.
      #
      # @param [String] change one of: add, modify, delete, replace
      # @param [Array<RelatonBib::Element::Classification>] classification
      # @param [Array<RelatonBib::Contributor>] contributor
      # @param [String, nil] id
      # @param [String, nil] path
      # @param [String, nil] path_end
      # @param [String, nil] title
      # @param [RelatonBib::T::AmendType::Location, nil] location
      # @param [RelatonBib::Element::AmendType::Description, nil] description
      # @param [RelatonBib::Element::AmendType::Newcontent, nil] newcontent
      #
      def initialize(change:, classification: [], contributor: [], **args) # rubocop:disable Metrics/MethodLength
        unless CHANGE.include? change
          Util.warn "amend[@change=\"#{change}\"] is invalid, should be one of: #{CHANGE.join(', ')}"
        end
        @change = change
        @classification = classification
        @contributor = contributor
        @id = args[:id]
        @path = args[:path]
        @path_end = args[:path_end]
        @title = args[:title]
        @location = args[:location]
        @description = args[:description]
        @newcontent = args[:newcontent]
      end

      def to_xml(builder) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        builder.parent[:id] = id if id
        builder.parent[:change] = change
        builder.parent[:path] = path if path
        builder.parent[:path_end] = path_end if path_end
        builder.parent[:title] = title if title
        location&.to_xml builder
        description&.to_xml builder
        newcontent&.to_xml builder
        classification.each { |c| c.to_xml builder }
        contributor.each { |c| c.to_xml builder }
      end
    end

    class Amend < AmendType
      def to_xml(builder)
        builder.amend { |b| super b }
      end
    end
  end
end
