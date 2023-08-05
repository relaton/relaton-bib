module RelatonBib
  module Util
    extend self

    def method_missing(...)
      logger.send(...)
    end

    def respond_to_missing?(method_name, include_private = false)
      logger.respond_to?(method_name) || super
    end

    def logger
      RelatonBib.configuration.logger
    end
  end
end
