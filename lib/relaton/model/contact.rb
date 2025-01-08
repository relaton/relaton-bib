require_relative "address"
require_relative "phone"
require_relative "uri"

module Relaton
  module Model
    module Contact
      def self.included(base)
        base.instance_eval do
          attribute :address, Address, collection: true
          attribute :phone, Phone, collection: true
          attribute :email, :string, collection: true
          attribute :uri, Uri, collection: true
        end
      end
    end
  end
end
