module Relaton
  module Bib
    # DateTime type that always uses +00:00 offset notation for UTC
    # instead of the Z shorthand in XML serialization.
    class DateTimeOffset < Lutaml::Model::Type::DateTime
      Lutaml::Model::Type::Value.register_format_type_serializer(
        :xml, self,
        to: lambda { |inst|
          return nil unless inst.value

          Lutaml::Model::Type::DateTime.format_datetime_iso8601(inst.value)
        }
      )
    end

    class Validity < Lutaml::Model::Serializable
      attribute :begins, DateTimeOffset
      attribute :ends, DateTimeOffset
      attribute :revision, DateTimeOffset

      xml do
        root "validity"
        map_element "validityBegins", to: :begins
        map_element "validityEnds", to: :ends
        map_element "revision", to: :revision
      end

      key_value do
        map "begins", to: :begins
        map "ends", to: :ends
        map "revision", to: :revision
      end
    end
  end
end
