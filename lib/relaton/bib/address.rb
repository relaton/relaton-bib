# frozen_string_literal: true

require "uri"

module Relaton
  module Bib
    # Address class.
    class Address
      # @return [Array<String>]
      attr_reader :street

      # @return [String, nil]
      attr_reader :city, :state, :country, :postcode, :formatted_address

      # @param street [Array<String>] streets
      # @param city [String, nil] city, should be present or formatted address provided
      # @param state [String, nil] state
      # @param country [String, nil] country, should be present or formatted address provided
      # @param postcode [String, nil] postcode
      # @param formatted_address [String, nil] formatted address, should be present or city and country provided
      def initialize(**args) # rubocop:disable Metrics/CyclomaticComplexity
        unless args[:formatted_address] || (args[:city] && args[:country])
          raise ArgumentError, "Either formatted address or city and country must be provided"
        end

        @street   = args[:street] || []
        @city     = args[:city]
        @state    = args[:state]
        @country  = args[:country]
        @postcode = args[:postcode]
        @formatted_address = args[:formatted_address] unless args[:city] && args[:country]
      end

      # @param doc [Nokogiri::XML::Document]
      # def to_xml(doc) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      #   doc.address do
      #     if formatted_address
      #       doc.formattedAddress formatted_address
      #     else
      #       street.each { |str| doc.street str }
      #       doc.city city
      #       doc.state state if state
      #       doc.country country
      #       doc.postcode postcode if postcode
      #     end
      #   end
      # end

      # @return [Hash]
      # def to_hash # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      #   hash = { "address" => {} }
      #   if formatted_address
      #     hash["address"]["formatted_address"] = formatted_address
      #   else
      #     hash["address"]["street"] = street if street.any?
      #     hash["address"]["city"] = city
      #     hash["address"]["state"] = state if state
      #     hash["address"]["country"] = country
      #     hash["address"]["postcode"] = postcode if postcode
      #   end
      #   hash
      # end

      # @param prefix [String]
      # @param count [Integer] number of addresses
      # @return [String]
      def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        pref = prefix.empty? ? "address" : "#{prefix}.address"
        if formatted_address
          "#{pref}.formatted_address:: #{formatted_address}\n"
        else
          out = count > 1 ? "#{pref}::\n" : ""
          street.each { |st| out += "#{pref}.street:: #{st}\n" }
          out += "#{pref}.city:: #{city}\n"
          out += "#{pref}.state:: #{state}\n" if state
          out += "#{pref}.country:: #{country}\n"
          out += "#{pref}.postcode:: #{postcode}\n" if postcode
          out
        end
      end
    end

    # Contact class.
    class Contact
      # @return [String] allowed "phone", "email" or "uri"
      attr_reader :type

      # @return [String, nil]
      attr_reader :subtype

      # @return [String]
      attr_reader :value

      # @param type [String] allowed "phone", "email" or "uri"
      # @param subtype [String, nil] i.e. "fax", "mobile", "landline" for "phone"
      #                              or "work", "personal" for "uri" type
      # @param value [String]
      def initialize(type:, value:, subtype: nil)
        @type     = type
        @subtype  = subtype
        @value    = value
      end

      # @param builder [Nokogiri::XML::Document]
      # def to_xml(builder)
      #   node = builder.send type, value
      #   node["type"] = subtype if subtype
      # end

      # @return [Hash]
      # def to_hash
      #   hash = { type => value }
      #   hash["type"] = subtype if subtype
      #   hash
      # end

      # @param prefix [String]
      # @param count [Integer] number of contacts
      # @return [string]
      def to_asciibib(prefix = "", count = 1)
        pref = prefix.empty? ? prefix : "#{prefix}."
        out = count > 1 ? "#{pref}contact::\n" : ""
        out += "#{pref}contact.#{type}:: #{value}\n"
        out += "#{pref}contact.type:: #{subtype}\n" if subtype
        out
      end
    end
    # # Contributor.
    # class Contributor
    #   # include Relaton

    #   # @return [URI]
    #   attr_reader :uri

    #   # @return [Array<Relaton::Bibb::Address, Relaton::Bibb::Contact>]
    #   attr_reader :contact

    #   # @param url [String, nil]
    #   # @param contact [Array<Relaton::Bibb::Address, Relaton::Bibb::Contact>]
    #   def initialize(url: nil, contact: [])
    #     @uri = URI url if url
    #     @contact = contact
    #   end

    #   # Returns url.
    #   # @return [String]
    #   def url
    #     @uri.to_s
    #   end

    #   # @params builder [Nokogiri::XML::Builder]
    #   def to_xml(builder)
    #     contact.each { |contact| contact.to_xml builder }
    #   end

    #   # @return [Hash]
    #   def to_hash
    #     hash = {}
    #     hash["url"] = uri.to_s if uri
    #     hash["contact"] = single_element_array(contact) if contact&.any?
    #     hash
    #   end

    #   # @param prefix [String]
    #   # @return [String]
    #   def to_asciibib(prefix = "") # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    #     pref = prefix.empty? ? prefix : "#{prefix}."
    #     out = ""
    #     out += "#{pref}url:: #{uri}\n" if uri
    #     addr = contact.select { |c| c.is_a? Relaton::Bibb::Address }
    #     addr.each { |ct| out += ct.to_asciibib prefix, addr.size }
    #     cont = contact.select { |c| c.is_a? Relaton::Bibb::Contact }
    #     cont.each { |ct| out += ct.to_asciibib prefix, cont.size }
    #     out
    #   end
    # end
  end
end
