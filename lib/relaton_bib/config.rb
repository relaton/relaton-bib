module RelatonBib
  module Config
    def configure
      yield configuration if block_given?
    end

    def configuration
      @configuration ||= self::Configuration.new
    end
  end

  class Configuration
    PROGNAME = "relaton-bib".freeze

    attr_reader :logger_pool

    def initialize
      @logger_pool = RelatonBib::LoggerPool.new
      @logger_pool << RelatonBib::Logger.new($stderr, level: ::Logger::INFO, progname: self.class::PROGNAME)
    end

    def logger_pool=(loggers)
      @logger_pool.loggers = loggers
    end
  end

  extend Config
end
