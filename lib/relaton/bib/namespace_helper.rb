module Relaton
  module Bib
    module NamespaceHelper
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def namespace
          @namespace = Object.const_get name.split("::")[0..1].join("::")
        end
      end

      private

      def namespace
        self.class.namespace
      end
    end
  end
end
