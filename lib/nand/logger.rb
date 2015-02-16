# -*-mode: ruby; coding: utf-8 -*-

require 'logger'

module Nand
  module Logging
    LOG_FATAL = ::Logger::FATAL
    LOG_ERROR = ::Logger::ERROR
    LOG_WARN  = ::Logger::WARN
    LOG_INFO  = ::Logger::INFO
    LOG_DEBUG = ::Logger::DEBUG

    def logger_output_params; [STDOUT] end
    def logger_formatter; TimeFormatter.new  end
    def logger_progname ; "" end
    def log
      @log ||= begin
                 logger = NandLogger.new(*logger_output_params)
                 logger.formatter = logger_formatter
                 logger.progname  = logger_progname
                 logger.level     = ::Logger::WARN
                 logger
               end
    end
    def logger_refresh; @log = nil end

    class SimpleFormatter < ::Logger::Formatter
      def call(severity, time, progname, msg)
        format = "%s\n"
        format % [msg2str(msg)]
      end
    end
    class TimeFormatter < ::Logger::Formatter
      def call(severity, time, progname, msg)
        # time PID ThreadID LEVEL progname message
        format = "%s #%d[%x] - %s - %s: %s\n"
        format % ["#{time.strftime('%H:%M:%S.%6N')}",
          $$, Thread.current.object_id, severity[0...1], progname, msg2str(msg)]
      end
    end


    class NandLogger < Logger
      def initialize(logdev, shift_age=nil, shift_size=nil)
        @progname = nil
        @level = DEBUG
        @default_formatter = Formatter.new
        @formatter = nil
        @logdev = nil
        if logdev
          @logdev = LocklessLogDevice.new(logdev)
        end
      end
      class LocklessLogDevice < LogDevice

        def initialize(log = nil)
          @dev = @filename = @shift_age = @shift_size = nil
          if log.respond_to?(:write) and log.respond_to?(:close)
            @dev = log
          else
            @dev = open_logfile(log)
            @dev.sync = true
            @filename = log
          end
        end
        def write(message)
          @dev.write(message)
        rescue Exception => ignored
          warn("log writing failed. #{ignored}")
        end

        def close
          @dev.close rescue nil
        end

        private

        def open_logfile(filename)
          if (FileTest.exist?(filename))
            open(filename, (File::WRONLY | File::APPEND))
          else
            create_logfile(filename)
          end
        end

        def create_logfile(filename)
          logdev = open(filename, (File::WRONLY | File::APPEND | File::CREAT))
          logdev.sync = true
          add_log_header(logdev)
          logdev
        end

        def add_log_header(file)
          file.write( "# Logfile created on %s by %s\n" % [Time.now.to_s, Logger::ProgName])
        end

      end
    end
  end
end
