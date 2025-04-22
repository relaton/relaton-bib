require_relative "rfc_address"

module Relaton
  module Bib
    module Parser
      module RfcContacts
        def initialize(author)
          @author = author
        end

        def address
          RfcAddress.transform(@author.address)
        end

        def phone
          return [] unless @author.address&.phone

          [Phone.new(content: @author.address.phone.content)]
        end

        def email
          return [] unless @author.address&.email

          @author.address.email.map(&:content)
        end

        def uri
          return [] unless @author.address&.uri

          [Uri.new(content: @author.address.uri.content)]
        end
      end
    end
  end
end
