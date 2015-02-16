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
    def logger_formatter; SimpleFormatter.new  end
    def logger_progname ; "" end
    def log
      @log ||= begin
                 logger = ::Logger.new(*logger_output_params)
                 logger.formatter = logger_formatter
                 logger.progname  = logger_progname
                 logger.level     = LOG_WARN
                 logger
               end
    end
    def log_debug!; log.level = LOG_DEBUG end

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
  end
end
