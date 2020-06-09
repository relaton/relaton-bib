require "relaton_bib/version"
require "relaton_bib/deep_dup"
require "relaton_bib/bibliographic_item"
require "relaton_bib/hit_collection"
require "relaton_bib/hit"

module RelatonBib
  class Error < StandardError; end

  class RequestError < StandardError; end

  class << self
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    # @param date [String]
    # @return [Date, NilClass]
    def parse_date(sdate)
      if sdate.is_a?(Date) then sdate
      elsif /(?<date>\w+\s\d{4})/ =~ sdate # February 2012
        Date.strptime(date, "%B %Y")
      elsif /(?<date>\w+\s\d{1,2},\s\d{4})/ =~ sdate # February 11, 2012
        Date.strptime(date, "%B %d, %Y")
      elsif /(?<date>\d{4}-\d{2}-\d{2})/ =~ sdate # 2012-02-11
        Date.parse(date)
      elsif /(?<date>\d{4}-\d{2})/ =~ sdate # 2012-02
        Date.strptime date, "%Y-%m"
      elsif /(?<date>\d{4})/ =~ sdate then Date.strptime date, "%Y" # 2012
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  end

  private

  # @param array [Array]
  # @return [Array<String>, String]
  def single_element_array(array)
    if array.size > 1
      array.map { |e| e.is_a?(String) ? e : e.to_hash }
    else
      array[0].is_a?(String) ? array[0] : array[0].to_hash
    end
  end
end
