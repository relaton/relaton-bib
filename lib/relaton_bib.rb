require "forwardable"
require "yaml"
require "htmlentities"
require "relaton_bib/version"
require "relaton_bib/deep_dup"
require "relaton_bib/localized_string"
require "relaton_bib/bibliographic_item"
require "relaton_bib/hit_collection"
require "relaton_bib/hit"
require "relaton_bib/bibxml_parser"

module RelatonBib
  class Error < StandardError; end

  class RequestError < StandardError; end

  class << self
    # @param date [String, Integer, Date] date
    # @param str [Boolean] return string or Date
    # @return [Date, String, nil] date
    def parse_date(date, str = true) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity,Metrics/AbcSize
      return date if date.is_a?(Date)

      case date.to_s
      when /(?<date>\w+\s\d{4})/ # February 2012
        d = Date.strptime($~[:date], "%B %Y")
        str ? d.strftime("%Y-%m") : d
      when /(?<date>\w+\s\d{1,2},\s\d{4})/ # February 11, 2012
        d = Date.strptime($~[:date], "%B %d, %Y")
        str ? d.strftime("%Y-%m-%d") : d
      when /(?<date>\d{4}-\d{2}-\d{2})/ # 2012-02-11
        str ? $~[:date] : Date.strptime($~[:date], "%Y-%m-%d")
      when /(?<date>\d{4}-\d{2})/ # 2012-02
        str ? $~[:date] : Date.strptime($~[:date], "%Y-%m")
      when /(?<date>\d{4})/ # 2012
        str ? $~[:date] : Date.strptime($~[:date], "%Y")
      end
    end

    # @param arr [NilClass, Array, #is_a?]
    # @return [Array]
    def array(arr)
      return [] unless arr
      return [arr] unless arr.is_a?(Array)

      arr
    end

    #
    # Parse yaml content
    #
    # @param [String] yaml content
    #
    # @return [Hash] data
    #
    def parse_yaml(yaml, classes = [])
      # Newer versions of Psych uses the `permitted_classes:` parameter
      if YAML.method(:safe_load).parameters.map(&:last).include? :permitted_classes
        YAML.safe_load(yaml, permitted_classes: classes)
      else
        YAML.safe_load(yaml, classes)
      end
    end
  end

  private

  # @param array [Array]
  # @return [Array<String>, String]
  def single_element_array(array)
    # if array.size > 1
    array.map { |e| e.is_a?(String) ? e : e.to_hash }
    # else
    #   array.first.is_a?(String) ? array[0] : array.first&.to_hash
    # end
  end
end
