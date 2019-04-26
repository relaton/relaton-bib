# frozen_string_literal: true

module RelatonBib
  #
  # Series class.
  #
  class Series
    TYPES = %w[main alt].freeze

    # @return [String, NilClass] allowed values: "main" or "alt"
    attr_reader :type

    # @return [RelatonBib::FormattedRef, NilClass]
    attr_reader :formattedref

    # @return [RelatonBib::FormattedString, NilClass] title
    attr_reader :title

    # @return [String, NilClass]
    attr_reader :place

    # @return [String, NilClass]
    attr_reader :organization

    # @return [RelatonBib::LocalizedString, NilClass]
    attr_reader :abbreviation

    # @return [String, NilClass] date or year
    attr_reader :from

    # @return [String, NilClass] date or year
    attr_reader :to

    # @return [String, NilClass]
    attr_reader :number

    # @return [String, NilClass]
    attr_reader :partnumber

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

    # @param type [String, NilClass] title or formattedref argument should be passed
    # @param formattedref [RelatonBib::FormattedRef, NilClass]
    # @param title [RelatonBib::TypedTitleString, NilClass]
    # @param place [String, NilClass]
    # @param orgaization [String, NilClass]
    # @param abbreviation [RelatonBib::LocalizedString, NilClass]
    # @param from [String, NilClass]
    # @param to [String, NilClass]
    # @param number [String, NilClass]
    # @param partnumber [String, NilClass]
    def initialize(**args)
      unless args[:title].is_a?(RelatonBib::TypedTitleString) || args[:formattedref]
        raise ArgumentError, "argument `title` or `formattedref` should present"
      end

      if args[:type] && !TYPES.include?(args[:type])
        raise ArgumentError, "invalid argument `type`"
      end

      @type         = args[:type] # if %w[main alt].include? args[:type]
      @title        = args[:title]
      @formattedref = args[:formattedref]
      @place        = args[:place]
      @organization = args[:organization]
      @abbreviation = args[:abbreviation]
      @from         = args[:from]
      @to           = args[:to]
      @number       = args[:number]
      @partnumber  = args[:partnumber]
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.series type: type do
        if formattedref
          formattedref.to_xml builder
        else
          builder.title { title.to_xml builder }
          builder.place place if place
          builder.organization organization if organization
          builder.abbreviation { abbreviation.to_xml builder } if abbreviation
          builder.from from if from
          builder.to to if to
          builder.number number if number
          builder.partnumber partnumber if partnumber
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
