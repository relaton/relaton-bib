# frozen_string_literal: true

require "time"

module RelatonBib
  # Bibliographic date.
  class BibliographicDate
    TYPES = %w[published accessed created implemented obsoleted confirmed
               updated issued transmitted copied unchanged circulated
    ].freeze

    # @return [String]
    attr_reader :type

    # @return [Date]
    attr_reader :from

    # @return [Date]
    attr_reader :to

    # @return [Date]
    attr_reader :on

    # @param type [String] "published", "accessed", "created", "activated"
    # @param from [String]
    # @param to [String]
    def initialize(type:, on: nil, from: nil, to: nil)
      raise ArgumentError, "expected :on or :from argument" unless on || from

      TYPES.include?(type) or
        raise ArgumentError, %{Type "#{type}" is invalid.} unless

      @type = type
      @on   = parse_date on
      @from = parse_date from
      @to   = parse_date to
    end

    # rubocop:disable Metrics/AbcSize

    # @param builder [Nokogiri::XML::Builder]
    # @return [Nokogiri::XML::Builder]
    def to_xml(builder, **opts)
      builder.date(type: type) do
        if on
          builder.on(opts[:no_year] ? "--" : date_format(on, opts[:date_format]))
        elsif from
          builder.from(opts[:no_year] ? "--" : date_format(from, opts[:date_format]))
          builder.to date_format(to, opts[:date_format]) if to
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    # @return [Hash]
    def to_hash
      hash = { type: type }
      hash[:value] = on.to_s if on
      hash[:from] = from.to_s if from
      hash[:to] = to.to_s if to
      hash
    end

    private

    # Formats date
    # @param date [Time]
    # @param format [Symbol, nil] :full (yyyy-mm-dd), :short (yyyy-mm) or nil (yyyy)
    # @return [String]
    def date_format(date, format = nil)
      case format
      when :short then date.strftime "%Y-%m"
      when :full then date.strftime "%Y-%m-%d"
      else date.year
      end
    end

    # @params date [String] 'yyyy', 'yyyy-mm', 'yyyy-mm-dd
    # @return [Date]
    def parse_date(date)
      return unless date

      if date =~ /^\d{4}$/
        Date.strptime date, "%Y"
      elsif date =~ /^\d{4}-\d{2}$/
        Date.strptime date, "%Y-%m"
      elsif date =~ /\d{4}-\d{2}-\d{2}$/
        Date.strptime date, "%Y-%m-%d"
      end
    end
  end
end
