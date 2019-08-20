require "relaton_bib/version"
require "relaton_bib/bibliographic_item"

module RelatonBib
  class Error < StandardError; end

  class RequestError < StandardError; end

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
