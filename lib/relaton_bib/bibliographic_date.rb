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

    # @param part [Symbol] :year, :month, :day, :date
    # @return [String, Date, nil]
    def from(part = nil)
      d = instance_variable_get "@#{__callee__}".to_sym
      return d unless part

      date = parse_date(d)
      return date if part == :date

      date.send part
    end

    alias_method :to, :from
    alias_method :on, :from

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
    # @param date [String]
    # @param format [Symbol, nil] :full (yyyy-mm-dd), :short (yyyy-mm) or nil
    # @return [String]
    def date_format(date, format = nil)
      case format
      when :short then parse_date(date).strftime "%Y-%m"
      when :full then parse_date(date).strftime "%Y-%m-%d"
      else date
      end
    end

    # @param date [String]
    # @return [Date]
    def parse_date(date)
      case date
      when /\d{4}-\d{2}-\d{2}/ then Date.parse(date) # 2012-02-11
      when /\d{4}-\d{2}/ then Date.strptime(date, "%Y-%m") # 2012-02
      when /\d{4}/ then Date.strptime(date, "%Y") # 2012
      end
    end
  end
end
