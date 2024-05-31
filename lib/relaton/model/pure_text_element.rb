module Relaton
  module Model
    module PureTextElement
      def self.included(base)
        base.instance_eval do
          attribute :content, Shale::Type::String

          xml do
            map_content to: :content
          end
        end
      end
    end
  end
end
