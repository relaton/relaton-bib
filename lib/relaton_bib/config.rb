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

    attr_accessor :logger

    def initialize
      @logger = ::Logger.new $stderr
      @logger.level = ::Logger::WARN
      @logger.progname = self.class::PROGNAME
      @logger.formatter = proc do |_severity, _datetime, progname, msg|
        "[#{progname}] #{msg}\n"
      end
    end
  end

  extend Config
end
