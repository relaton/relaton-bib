# frozen_string_literal: true

require "time"

module RelatonBib
  # Bibliographic date.
  class BibliographicDate
    TYPES = %w[published accessed created implemented obsoleted confirmed
               updated corrected issued transmitted copied unchanged circulated adapted
               vote-started vote-ended announced stable-until].freeze

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
    def from(part = nil) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      d = instance_variable_get "@#{__callee__}".to_sym
      return d unless part && d

      # date = parse_date(d)
      # return date if part == :date

      parts = d.split "-"
      case part
      when :year then parts[0]&.to_i
      when :month then parts[1]&.to_i
      when :day then parts[2]&.to_i
      when :date then parse_date(d)
      else d
      end

      # date.is_a?(Date) ? date.send(part) : date
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
      pref = prefix.empty? ? prefix : "#{prefix}."
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
      tmplt = case format
              when :short then "%Y-%m"
              when :full then "%Y-%m-%d"
              else return date
              end
      d = parse_date(date)
      d.is_a?(Date) ? d.strftime(tmplt) : d
    end

    # @param date [String]
    # @return [Date]
    def parse_date(date)
      case date
      when /^\d{4}-\d{1,2}-\d{1,2}/ then Date.parse(date) # 2012-02-11
      when /^\d{4}-\d{1,2}/ then Date.strptime(date, "%Y-%m") # 2012-02
      when /^\d{4}/ then Date.strptime(date, "%Y") # 2012
      else date
      end
    end
  end
end
