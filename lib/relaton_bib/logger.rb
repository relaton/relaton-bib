require "logger"

module RelatonBib
  class LoggerPool
    extend Forwardable
    def_delegators :@loggers, :<<, :[], :first, :last, :empty?, :any?, :size, :each, :detect, :length

    attr_accessor :loggers

    def initialize
      @loggers = []
    end

    def unknown(progname = nil, **args, &block)
      @loggers.each { |logger| logger.send(__callee__, progname, **args, &block) }
    end

    %i[fatal error warn info debug].each { |m| alias_method m, :unknown }

    def truncate
      @loggers.each &:truncate
    end
  end

  class Logger < ::Logger
    def initialize(logdev, shift_age = 0, shift_size = 1048576, **args) # rubocop:disable Lint/MissingSuper
      self.level = args.delete(:level) || DEBUG
      self.progname = args.delete(:progname)
      @default_formatter = FormatterString.new
      self.datetime_format = args.delete(:datetime_format)
      self.formatter = args.delete(:formatter)
      @logdev = nil
      @level_override = {}
      if logdev && logdev != File::NULL
        @logdev = LogDevice.new(logdev, shift_age: shift_age, shift_size: shift_size, **args)
      end
    end

    def unknown(progname = nil, **args, &block)
      level = Object.const_get "Logger::#{__callee__.to_s.upcase}"
      add(level, nil, progname, **args, &block)
    end

    %i[fatal error warn info debug].each { |m| alias_method m, :unknown }

    def add(severity, message = nil, progname = nil, **args) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      severity ||= UNKNOWN
      if @logdev.nil? || severity < @level
        return true
      end

      if progname.nil?
        progname = @progname
      end
      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @progname
        end
      end
      @logdev.write format_message(format_severity(severity), Time.now, progname, message, **args)
      true
    end

    def format_message(severity, datetime, progname, msg, **args)
      (@formatter || @default_formatter).call(severity, datetime, progname, msg, **args)
    end

    def truncate
      @logdev.truncate
    end

    class FormatterString < ::Logger::Formatter
      def call(severity, datetime, progname, msg, **args)
        output = []
        output << "[#{progname}]" if progname
        output << "#{severity}:"
        output << "(#{args[:key]})" if args[:key]
        output << "#{msg}\n"
        output.join " "
      end
    end

    class FormatterJSON < ::Logger::Formatter
      def call(severity, _datetime, progname, msg, **args)
        hash = { prog: progname, message: msg, severity: severity }.merge(args)
        hash.to_json
      end
    end

    class LogDevice < ::Logger::LogDevice
      def truncate
        return unless @dev.respond_to? :truncate

        @dev.truncate 0
        @dev.rewind
      end
    end
  end
end
