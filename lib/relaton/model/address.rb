module Relaton
  module Model
    class Street < Lutaml::Model::Serializable
      attribute :content, Lutaml::Model::Type::String

      xml do
        map_content :content
      end
    end

    class City < Lutaml::Model::Serializable
      attribute :content, Lutaml::Model::Type::String

      xml do
        map_content :content
      end
    end

    class State < Lutaml::Model::Serializable
      attribute :content, Lutaml::Model::Type::String

      xml do
        map_content :content
      end
    end

    class Country < Lutaml::Model::Serializable
      attribute :content, Lutaml::Model::Type::String

      xml do
        map_content :content
      end
    end

    class Postcode < Lutaml::Model::Serializable
      attribute :content, Lutaml::Model::Type::String

      xml do
        map_content :content
      end
    end

    class FormattedAddress < Lutaml::Model::Serializable
      attribute :content, Lutaml::Model::Type::String

      xml do
        map_content :content
      end
    end

    class Address < Lutaml::Model::Serializable
      attribute :street, Street, collection: true
      attribute :city, City
      attribute :state, State
      attribute :country, Country
      attribute :postcode, Postcode
    end
  end
end
