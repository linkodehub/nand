# -*-mode: ruby; coding: utf-8 -*-

require 'pathname'
require 'nand/proc_operation'
require 'nand/logger'

module Nand
  class Daemon
    extend ProcOperation
    include Logging
    def logger_output_params; [@daemon_log] end
    def logger_progname; @execname end
    attr_reader :execname, :run_dir
    def initialize(run_dir, execname, opts = {} )
      @run_dir = Pathname.new(run_dir)
      @execname = execname.to_s
      @launcher = opts[:launcher]
      @arg_uid  = opts[:uid]
      @pid_file = @run_dir.join(self.class.pid_filename(@execname))
      @daemon_log = opts[:daemon_log] || "/dev/null"
      @daemon_out = opts[:daemon_out] || "/dev/null"
      @daemon_err = opts[:daemon_err] || "/dev/null"
      @limit = opts[:sec]

      log.level  = LOG_DEBUG if opts[:debug]
    end
    def user
      Etc.getpwuid(uid).name
    rescue => e
      nil
    end
    def uid;  @arg_uid || Process.uid  end
    def running?; @pid_file.exist? and self.class.running_with?(pid, @execname) end

    def run
      raise "Launcher is Not Specified for #{@execname}" if @launcher.nil?
      raise "PID file exist #{@pid_file}" if @pid_file.exist?
      daemonize
    end
    def stop; stop_with_signal(:TERM) end
    def kill; stop_with_signal(:KILL) end
    def pid;  @pid ||=self.class.pid_from_pidfile(@pid_file) end

    private
    def daemonize( &block )
      if child = Process.fork
        Process.waitpid(child) # wait until exit child process
        return child
      end
      Process.setsid
      exit(0) if Process.fork # double fork and exit child process
      Dir.chdir(@run_dir)
      File.umask(0)
      STDIN.reopen("/dev/null")
      STDOUT.reopen(@daemon_out)
      STDERR.reopen(@daemon_err)

      begin
        File.open(@pid_file, "w"){|fs| fs.puts Process.pid }
        logger_refresh
        log.info "Daemonize!!!"

        Signal.trap(:INT)  {log.warn("RECEVIED SIG_INT")  ; signal_send_and_exit(:INT)}
        Signal.trap(:TERM) {log.warn("RECEVIED SIG_TERM") ; signal_send_and_exit(:TERM)}

        @child = @launcher.launch
        raise "Failed Launch for #{@execname}" if @child.nil?

        if !@limit.nil? and 0 < @limit
          Signal.trap(:SIGCHLD) {exit 0 }
          pid, status = Process.waitpid2(@child, Process::WNOHANG)
          if pid.nil?
            log.info "Child[#{@child}] will be Stopped after #{@limit} sec"
            sleep @limit
            Signal.trap(:SIGCHLD, "IGNORE")
            log.info "Send Signal TERM to Child[#{@child}] #{@limit} sec past"
            Process.kill(:TERM, @child)
          end
        end
        Process.waitpid2(@child) unless @child.nil?
        @child = nil
      rescue => e
        log.fatal e.message
        log.debug "\n\t" + e.backtrace.join("\n\t")
      ensure
        @pid_file.delete if @pid_file.exist?
      end
    end
    def signal_send_and_exit(type)
      Process.kill(type, @child) unless @child.nil?
    rescue => e
      exit -1
    end
    private
    def stop_with_signal(signal)
      raise "Can Not Send #{signal.to_s.capitalize} Signal to #{@execname}" unless uid == Process.uid or uid == 0
      unless running?
        @pid_file.delete if @pid_file.exist?
        raise "#{@execname} is Not Running"
      end
      Process.kill(signal, pid)
    end
  end
end
