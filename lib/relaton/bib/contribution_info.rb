require_relative "person"
require_relative "organization"

module Relaton
  module Bib
    class ContributionInfo
      attr_accessor :person, :organization

      def initialize(person: nil, organization: nil)
        @person = person
        @organization = organization
      end
    end
  end
end
