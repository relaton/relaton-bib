# frozen_string_literal: true

module RelatonBib
  # Contributor.
  class Contributor
    # @return [URI]
    attr_reader :uri

    # @return [Array<RelatonBib::Address, RelatonBib::Contact>]
    attr_reader :contact

    # @param url [String, nil]
    # @param contact [Array<RelatonBib::Address, RelatonBib::Contact>]
    def initialize(url: nil, contact: [])
      @uri = URI url if url
      @contact = contact
    end

    # Returns url.
    # @return [String]
    def url
      @uri.to_s
    end

    # @params builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      contact.each { |contact| contact.to_xml builder }
    end

    # @return [Hash]
    def to_hash
      hash = {}
      hash["url"] = uri.to_s if uri
      hash["contact"] = contact.map(&:to_hash) if contact&.any?
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "") # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      pref = prefix.empty? ? prefix : "#{prefix}."
      out = ""
      out += "#{pref}url:: #{uri}\n" if uri
      addr = contact.select { |c| c.is_a? RelatonBib::Address }
      addr.each { |ct| out += ct.to_asciibib prefix, addr.size }
      cont = contact.select { |c| c.is_a? RelatonBib::Contact }
      cont.each { |ct| out += ct.to_asciibib prefix, cont.size }
      out
    end
  end
end
