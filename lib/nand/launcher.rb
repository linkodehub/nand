# -*-mode: ruby; coding: utf-8 -*-

require 'pathname'

module Nand
  module Launcher
    def self.find(target, opts = {}, *argv)
      require 'nand/launcher/executable_file_launcher'
      require 'nand/launcher/shell_launcher'
      require 'nand/launcher/rb_file_launcher'
      require 'nand/launcher/plugin_launcher'

      err = StringIO.new("", "w")
      launcher_klass = [ExecutableFileLauncher, RbFileLauncher, PluginLauncher, ShellLauncher].find do |klass|
        klass.launchable? target, err, opts
      end
      raise "Not Found Executable #{target}:\n#{io.string}" if launcher_klass.nil?
      launcher = launcher_klass.load(target, opts, *argv)
      raise "Not be Ready for #{target} Launcher" unless launcher.ready?
      launcher
    end

    class Base
      def self.launchable?(target, io, *argv)
        raise "Not Implemented #{__method__} in #{self.name}"
      end
      def self.load( target, opts, *argv)
        raise "Not Implemented #{__method__} in #{self.name}"
      end
      attr_reader :execname
      def initialize(target, opts, *argv)
        @progname    = target
        @execname    = opts[:name] || File.basename(target)
        @exec_stdout = opts[:out]  || "/dev/null"
        @exec_stderr = opts[:err]  || "/dev/null"
        @exec_stdin  = opts[:in]   || "/dev/null"
        @argv   = argv
      end
      def launch; end
      def ready?
        [@exec_stdout, @exec_stderr].each do |out|
          next if out.is_a? IO
          path = Pathname.new(out)
          raise "Illegal Output File #{path.to_s}" unless (path.exist? and path.writable?) or
            (!path.exist? and path.dirname.writable?)
        end
        return true if @exec_stdin.is_a? IO
        path = Pathname.new(@exec_stdin)
        raise "Illegal Input File #{@exec_stdin.to_s}" unless path.exist? and path.readable?
        true
      end
    end
  end
end
