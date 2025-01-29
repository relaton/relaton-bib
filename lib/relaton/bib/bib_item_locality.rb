module Relaton
  module Bib
    module BibItemLocality
      def self.included(base) # rubocop:disable Metrics/MethodLength
        base.class_eval do
          attribute :type, :string, pattern: %r{
            section|clause|part|paragraph|chapter|page|title|line|whole|table|annex|
            figure|note|list|example|volume|issue|time|anchor|locality:[a-zA-Z0-9_]+
          }x
          attribute :reference_from, :string
          attribute :reference_to, :string

          xml do
            map_attribute "type", to: :type
            map_element "referenceFrom", to: :reference_from
            map_element "referenceTo", to: :reference_to
          end
        end
      end
    end
  end
end
