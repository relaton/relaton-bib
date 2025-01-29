require_relative "pure_text_element"

module Relaton
  module Bib
    class LocalizedString < LocalizedStringAttrs
      include PureTextElement

      attribute :content, :string

      def self.inherited(base)
        super
        base.class_eval do
          mappings[:xml].instance_eval do
            map_all to: :content
          end
        end
      end
    end
  end
end
