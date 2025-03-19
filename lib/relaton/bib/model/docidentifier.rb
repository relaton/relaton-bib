module Relaton
  module Bib
    class Docidentifier < LocalizedMarkedUpString
      attribute :type, :string
      attribute :scope, :string
      attribute :primary, :boolean

      xml do
        map_attribute "type", to: :type
        map_attribute "scope", to: :scope
        map_attribute "primary", to: :primary
      end

      def remove_part
        raise NotImplementedError, "remove_part method not implemented in #{self.class}"
      end

      def to_all_parts
        raise NotImplementedError, "to_all_parts method not implemented in #{self.class}"
      end

      def remove_date
        raise NotImplementedError, "remove_date method not implemented in #{self.class}"
      end
    end
  end
end
