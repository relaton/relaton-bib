module Relaton
  module Bib
    class TypedUri < LocalizedStringAttrs
      attribute :type, :string
      attribute :content, :string

      def self.inherited(base)
        super
        base.class_eval do
          mappings[:xml].instance_eval do
            map_attribute "type", to: :type
            map_content to: :content
          end
        end
      end
    end
  end
end
