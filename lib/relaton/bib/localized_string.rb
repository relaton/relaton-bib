module Relaton
  module Bib
    class LocalizedString < LocalizedStringAttrs
      attribute :content, :string

      def self.inherited(base)
        super
        base.class_eval do
          xml do
            map_all to: :content
          end
        end
      end
    end

    class TypedLocalizedString < LocalizedString
      attribute :type, :string

      xml do
        map_attribute "type", to: :type
      end
    end

    class LocalizedMarkedUpString < LocalizedString
    end
  end
end
