module RelatonBib
  module Util
    extend self

    def method_missing(method_name, msg, key = nil)
      key_msg = key ? "(#{key}) #{msg}" : msg
      logger.send method_name, key_msg
    end

    def respond_to_missing?(method_name, include_private = false)
      logger.respond_to?(method_name) || super
    end

    def logger
      RelatonBib.configuration.logger_pool
    end
  end
end
