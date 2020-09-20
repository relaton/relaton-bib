# frozen_string_literal: true

require "time"

module RelatonBib
  # Bibliographic date.
  class BibliographicDate
    TYPES = %w[published accessed created implemented obsoleted confirmed
               updated issued transmitted copied unchanged circulated adapted
               vote-started vote-ended].freeze

    # @return [String]
    attr_reader :type

    # @return [Date]
    attr_reader :from

    # @return [Date]
    attr_reader :to

    # @return [Date]
    attr_reader :on

    # @param type [String] "published", "accessed", "created", "activated"
    # @param on [String]
    # @param from [String]
    # @param to [String]
    def initialize(type:, on: nil, from: nil, to: nil)
      raise ArgumentError, "expected :on or :from argument" unless on || from

      # raise ArgumentError, "invalid type: #{type}" unless TYPES.include? type

      @type = type
      @on   = RelatonBib.parse_date on
      @from = RelatonBib.parse_date from
      @to   = RelatonBib.parse_date to
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
      hash = { "type" => type }
      hash["value"] = on.to_s if on
      hash["from"] = from.to_s if from
      hash["to"] = to.to_s if to
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of dates
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : prefix + "."
      out = count > 1 ? "#{pref}date::\n" : ""
      out += "#{pref}date.type:: #{type}\n"
      out += "#{pref}date.on:: #{on}\n" if on
      out += "#{pref}date.from:: #{from}\n" if from
      out += "#{pref}date.to:: #{to}\n" if to
      out
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
  end
end
