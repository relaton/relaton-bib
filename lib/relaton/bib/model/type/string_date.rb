require "forwardable"

module Relaton
  module Bib
    class StringDate < Lutaml::Model::Type::Value
      class Value
        include Comparable
        extend Forwardable
        extend Core::DateParser
        include Core::DateParser

        def_delegators :@value, :split, :to_s

        def initialize(value)
          @value = value
        end

        def self.parse_date(date)
          value = super
          new value if value
        end

        def <=>(other)
          return nil unless other.is_a?(Value)

          @value <=> other.to_s
        end

        def to_date
          parse_date(@value, str: false)
        rescue ArgumentError
          nil
        end
      end

      def self.cast(value)
        case value
        when Value then value
        when String then Value.parse_date(value)
        end
      end

      def to_yaml
        value.to_s
      end
    end
  end
end
