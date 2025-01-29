require_relative "locality"
require_relative "locality_stack"

module Relaton
  module Bib
    module CitationType
      def self.included(base) # rubocop:disable Metrics/MethodLength
        return unless base.is_a? Class

        base.class_eval do
          attribute :bibitemid, Lutaml::Model::Type::String
          attribute :locality, Locality, collection: true
          attribute :locality_stack, LocalityStack, collection: true
          attribute :date, Lutaml::Model::Type::String

          xml do
            map_attribute "bibitemid", to: :bibitemid
            # map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
            map_element "locality", to: :locality
            map_element "localityStack", to: :locality_stack
            map_element "date", to: :date
          end
        end
      end
    end
  end
end
