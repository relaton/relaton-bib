require_relative "pure_text_element"

module Relaton
  module Model
    class LocalizedString < LocalizedStringAttrs
      attribute :content, PureTextElement

      def self.inherited(base)
        super
        base.class_eval do
          mappings[:xml].instance_eval do
            map_content to: :content # , delegate: :content
          end
        end
      end
    end
  end
end
