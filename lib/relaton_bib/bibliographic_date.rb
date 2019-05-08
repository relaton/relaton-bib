# frozen_string_literal: true

require "time"

module RelatonBib
  # Bibliographic date.
  class BibliographicDate
    TYPES = %w[published accessed created implemented obsoleted confirmed
               updated issued].freeze

    # @return [String]
    attr_reader :type

    # @return [Time]
    attr_reader :from

    # @return [Time]
    attr_reader :to

    # @return [Time]
    attr_reader :on

    # @param type [String] "published", "accessed", "created", "activated"
    # @param from [String]
    # @param to [String]
    def initialize(type:, on: nil, from: nil, to: nil)
      raise ArgumentError, "expected :on or :form argument" unless on || from

      raise ArgumentError, %{Type "#{type}" is ivalid.} unless TYPES.include?(type)

      @type = type
      @on   = parse_date on
      @from = parse_date from
      @to   = parse_date to
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity

    # @param builder [Nokogiri::XML::Builder]
    # @return [Nokogiri::XML::Builder]
    def to_xml(builder, **opts)
      builder.date(type: type) do
        if on
          date = opts[:full_date] ? on.strftime("%Y-%m") : on.year
          builder.on(opts[:no_year] ? "--" : date)
        elsif from
          if opts[:full_date]
            date_form = from.strftime("%Y-%m")
            date_to = to.strftime("%Y-%m") if to
          else
            date_form = from.year
            date_to = to.year if to
          end
          builder.from(opts[:no_year] ? "--" : date_form)
          builder.to date_to if to
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity

    private

    # @params date [String] 'yyyy' or 'yyyy-mm'
    def parse_date(date)
      return unless date

      if date =~ /^\d{4}$/
        Time.strptime date, "%Y"
      elsif date =~ /^\d{4}-\d{2}$/
        Time.strptime date, "%Y-%m"
      elsif date =~ /\d{4}-\d{2}-\d{2}$/
        Time.strptime date, "%Y-%m-%d"
      end
    end
  end
end
