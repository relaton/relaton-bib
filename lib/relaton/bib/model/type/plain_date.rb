require "date"

module Relaton
  module Bib
    # xs:date value type that always casts to ::Date, dropping any time and
    # timezone component. Without this, lutaml-model's built-in Date type
    # promotes inputs like "2018-04-15T00:00:00Z" to ::DateTime and serializes
    # them back as "2018-04-15Z" — valid xs:date, but not valid ISO 8601.
    class PlainDate < Lutaml::Model::Type::Date
      def self.cast(value, options = {})
        result = super
        result.is_a?(::DateTime) ? result.to_date : result
      end
    end
  end
end
