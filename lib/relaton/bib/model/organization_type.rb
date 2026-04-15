module Relaton
  module Bib
    module OrganizationType
      class Identifier < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          root "identifier"
          map_attribute "type", to: :type
          map_content to: :content
        end
      end

      # Serialize name preserving original shape (single vs array)
      def name_to_kv(model, parent)
        val = model.name
        return if val.nil?

        if val.is_a?(Array)
          arr = val.map { |n| TypedLocalizedString.as_yaml(n) }
          parent["name"] = arr
        else
          parent["name"] = TypedLocalizedString.as_yaml(val)
        end
      end

      def name_from_kv(model, value)
        model.name = if value.is_a?(Array)
                       value.map do |v|
                         TypedLocalizedString.of_yaml(v)
                       end
                     else
                       TypedLocalizedString.of_yaml(value)
                     end
      end

      def self.included(base) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        require_relative "subdivision"

        base.instance_eval do
          include Contact

          attribute :name, TypedLocalizedString, collection: true, initialize_empty: true
          attribute :subdivision, Subdivision, collection: true, initialize_empty: true
          attribute :abbreviation, LocalizedString
          attribute :identifier, Identifier, collection: true, initialize_empty: true
          attribute :logo, Logo, collection: true, initialize_empty: true

          xml do
            map_element "name", to: :name
            map_element "subdivision", to: :subdivision
            map_element "abbreviation", to: :abbreviation
            map_element "identifier", to: :identifier
            map_element "address", to: :address
            map_element "phone", to: :phone
            map_element "email", to: :email
            map_element "uri", to: :uri
            map_element "logo", to: :logo
          end

          key_value do
            map "address", to: :address
            map "phone", to: :phone
            map "email", to: :email
            map "uri", to: :uri
            map "name", to: :name,
                        with: { to: :name_to_kv,
                                from: :name_from_kv }
            map "subdivision", to: :subdivision
            map "abbreviation", to: :abbreviation
            map "identifier", to: :identifier
            map "logo", to: :logo
          end
        end
      end
    end
  end
end
