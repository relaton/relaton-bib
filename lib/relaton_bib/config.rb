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
  end

  extend Config
end
