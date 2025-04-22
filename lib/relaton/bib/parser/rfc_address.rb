module Relaton
  module Bib
    module Parser
      # Class for transforming RFC Postal to Relaton Address
      class RfcAddress
        def initialize(postal)
          @postal = postal
        end

        #
        # Transform address from RFC Postal to Relaton Address
        #
        # @param [Rfcxml::V3::Address] address RFC Address
        #
        # @return [Array<Relaton::Bib::Address>]
        #
        def self.transform(address)
          return [] unless address&.postal

          new(address.postal).transform
        end

        def transform # rubocop:disable Metrics/CyclomaticComplexity
          street = @postal.street || []
          city = @postal.city || []
          region = @postal.region || []
          country = @postal.country || []
          code = @postal.code || []
          postal_line = @postal.postal_line || []
          transform_args(
            street: street, city: city, region: region, country: country, code: code, postal_line: postal_line,
          )
        end

        def transform_args(**args)
          i = 0
          addrs = []
          while args.values.any? { |v| v[i] }
            addrs << create_address(**args.transform_values { |v| v[i] })
            i += 1
          end
          addrs
        end

        def create_address(**args) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
          street = []
          street << args[:street]&.content if args[:street]
          Address.new(
            street: street,
            city: args[:city]&.content,
            state: args[:region]&.content,
            country: args[:country]&.content,
            postcode: args[:code]&.content,
            formatted_address: args[:postal_line]&.content,
          )
        end
      end
    end
  end
end
