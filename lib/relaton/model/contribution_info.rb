module Relaton
  module Model
    class ContributionInfo
      def initialize(entity)
        @entity = entity
      end

      def self.cast(value)
        value
      end

      def self.of_xml(node)
        if (n = node.at("person"))
          new Person.of_xml n
        elsif (n = node.at("organization"))
          new Organization.of_xml n
        end
      end
    end
  end
end
