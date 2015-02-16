# -*-mode: ruby; coding: utf-8 -*-

require 'pathname'
require 'thor'

require 'nand/daemon'
require 'nand/launcher_finder'

module Nand
  class Cli < Thor
    class_option :run_dir, :desc => "Specify running dir, Default is a Current Directory"
    class_option :debug, :type => :boolean, :default => false, :hide => true, :desc => "This is debug flag, Daemon process stdout/stderr pipes to this terminal"

    desc "start EXEC [OPTIONS] [-- EXEC OPTIONS]", "Start Daemon for EXEC with options"
    option :out, :aliases => '-o', :default => "/dev/null", :desc => "Daemon process STDOUT pipes to output file"
    option :err, :aliases => '-e', :default => "/dev/null", :desc => "Daemon process STDERR pipes to output error file"
    option :in, :aliases => '-i', :default => "/dev/null", :desc => "Daemon process STDIN  pipes to input file"
    option :name, :aliases => '-n', :desc => "Spcify Alias Name of Daemon process, default is first argument"
    option :sec, :aliases => '-s', :type => :numeric, :desc => "Running time of Daemon process for seconds"
    option :demon_out, :default => "/dev/null", :hide => true, :desc => "Daemon Process STDOUT pipes DEAMON_OUT"
    option :demon_err, :default => "/dev/null", :hide => true, :desc => "Daemon Process STDERR pipes DEAMON_ERR"
    option :demon_log, :default => "/dev/null", :desc => "Output Daemon Process Log file"

    def start(name, *argv)
      opts = restore_options(options.dup)
      dir = run_dir(opts)
      dir.mkpath unless dir.exist?
      launcher = find_launcher(name, opts, *argv)
      opts[:launcher] = launcher
      daemon = Daemon.new(dir, launcher.execname, opts)
      begin
        daemon.run
        sleep 0.1
        if daemon.running?
          puts "#{daemon.execname} is Start[#{daemon.pid}]"
        end
      rescue => e
        STDERR.puts "#{daemon.execname} is Start Failed [#{e.message}]"
        raise e
        #exit -1
      end
    end

    desc "status [EXEC_NAME] [OPTIONS]", "Show Running Daemon Process Status w/wo EXEC_NAME"
    option :all, :aliases => '-a', :type => :boolean, :desc => "All running Daemons Status in this Server"
    def status(name = nil)
      ds = if options[:all]
             Daemon.all_runnings
           else
             Daemon.running_in(run_dir(options), name)
           end
      ds.each do |d|
        puts status_message(d.run_dir, d.execname, d.running?, d.pid, d.user)
      end
      puts status_message(run_dir(options), name, false) unless ds.empty? and name.nil?
    end
    desc "stop [EXEC_NAME] [OPTIONS]", "Stop Daemon Process w/wo EXEC_NAME"
    option :all, :aliases => '-a', :type => :boolean, :desc => "All running Daemons Status in this Server"
    def stop(name = nil)
      dir = run_dir(options)
      ds = if options[:all]
             Daemon.all_runnings
           else
             Daemon.running_in(run_dir(options), name)
           end
      ds.each do |d|
        pid = d.pid
        if d.running?
          begin
            d.stop and puts "#{d.execname} is Stopped [#{pid}]"
          rescue => e
            puts "Stop #{d.execname} Failed [#{e.message}]"
          end
        else
          puts "#{d.execname} is Not Running"
        end
      end
      puts status_message(dir, name, false) if !name.nil? and ds.empty?
    end

    desc "version", ""
    def version
        puts File.basename($PROGRAM_NAME) + " " + VERSION
    end

    private
    def find_launcher(name, opts, *argv, &block)
      launcher = Nand::LauncherFinder.find( name, opts, *(argv + Nand.additional_argv) )
      if block_given?
        block.call(launcher)
      else
        launcher
      end
    end
    def run_dir(opts)
      Pathname.new(opts[:run_dir] || Dir.pwd)
    end
    def status_message(dir, name, running, pid = nil, user = nil)
      "#{name} is " + (running ? "Running [#{pid}] by #{user}" : "Not Running") + " in #{dir}"
    end
    no_tasks do
      # デフォルトメソッドを上書きして -h をヘルプ
      def invoke_task(task, *args)
        if options[:help]
          help(task.name)
        elsif options[:version] or args.flatten.first == "-v"
          version
        else
          super
        end
      end
    end
  end
end
