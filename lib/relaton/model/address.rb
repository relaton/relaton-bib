module Relaton
  module Model
    class Street < Shale::Mapper
      attribute :content, Shale::Type::String

      xml do
        map_content :content
      end
    end

    class City < Shale::Mapper
      attribute :content, Shale::Type::String

      xml do
        map_content :content
      end
    end

    class State < Shale::Mapper
      attribute :content, Shale::Type::String

      xml do
        map_content :content
      end
    end

    class Country < Shale::Mapper
      attribute :content, Shale::Type::String

      xml do
        map_content :content
      end
    end

    class Postcode < Shale::Mapper
      attribute :content, Shale::Type::String

      xml do
        map_content :content
      end
    end

    class FormattedAddress < Shale::Mapper
      attribute :content, Shale::Type::String

      xml do
        map_content :content
      end
    end

    class Address < Shale::Mapper
      attribute :street, Street, collection: true
      attribute :city, City
      attribute :state, State
      attribute :country, Country
      attribute :postcode, Postcode
    end
  end
end
