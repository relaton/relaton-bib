module RelatonBib
  module Util
    extend self

    PROGNAME = "relaton-bib".freeze

    def method_missing(method_name, msg = nil, prog = nil, **opts, &block)
      prog ||= self::PROGNAME
      Relaton.logger_pool.send method_name, msg, prog, **opts, &block
    end

    def respond_to_missing?(method_name, include_private = false)
      Relaton.logger_pool.respond_to?(method_name) || super
    end
  end
end
