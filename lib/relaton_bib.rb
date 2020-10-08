require "forwardable"
require "relaton_bib/version"
require "relaton_bib/deep_dup"
require "relaton_bib/localized_string"
require "relaton_bib/bibliographic_item"
require "relaton_bib/hit_collection"
require "relaton_bib/hit"

module RelatonBib
  class Error < StandardError; end

  class RequestError < StandardError; end

  class << self
    # @param date [String, Integer, Date]
    # @return [Date, NilClass]
    def parse_date(date) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      return date if date.is_a?(Date)

      sdate = date.to_s
      case sdate
      when /(?<date>\w+\s\d{4})/ # February 2012
        Date.strptime($~[:date], "%B %Y")
      when /(?<date>\w+\s\d{1,2},\s\d{4})/ # February 11, 2012
        Date.strptime($~[:date], "%B %d, %Y")
      when /(?<date>\d{4}-\d{2}-\d{2})/ # 2012-02-11
        Date.parse($~[:date])
      when /(?<date>\d{4}-\d{2})/ # 2012-02
        Date.strptime date, "%Y-%m"
      when /(?<date>\d{4})/ then Date.strptime $~[:date], "%Y" # 2012
      end
    end
  end

  private

  # @param array [Array]
  # @return [Array<String>, String]
  def single_element_array(array) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    if array.size > 1
      array.map { |e| e.is_a?(String) ? e : e.to_hash }
    else
      array.first&.is_a?(String) ? array[0] : array.first&.to_hash
    end
  end
end
