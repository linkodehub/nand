# -*-mode: ruby; coding: utf-8 -*-

require 'pathname'
require 'nand/launcher'

module Nand
  class RbAdapter
    class RbFileLauncher < Launcher
      def self.rb_file(target)
        Pathname.new(target).expand_path
      end
      def initialize(target, executor, opts, *argv)
        super(target, opts, *argv)
        @executor = executor
      end
      def launch
        if child = Process.fork
          child
        else
          begin
            STDIN.reopen(@exec_stdin)
            STDOUT.reopen(@exec_stdout)
            STDERR.reopen(@exec_stderr)
            Signal.trap(:INT)  {exit 0}
            Signal.trap(:TERM) {exit 0}
            Process.setpgrp
            @executor.exec
          rescue LoadError => e
            STDERR.puts e.message
          rescue => e
            STDERR.puts e.message
          ensure

          end
        end
      end
    end
    def self.connectable?( target, opts)
      return false unless target.to_s =~/\.rb$/
      require_rb(target) and
      true
    rescue LoadError => e
      false
      puts e.message
    rescue => e
      puts e.message

      false
    end
    def self.connect( target, opts, *argv )
      require_rb(target)
      plugin = opts[:plugin]
      raise "Option --plugin is Required for #{target}" if plugin.nil?
      executor = Plugin.plugin!(plugin, *argv)
      raise "Executor #{plugin} is Not Emplemented exec Method" unless executor.respond_to?(:exec)
      RbFileLauncher.new(target, executor, opts, *argv)
    rescue LoadError => e
        raise "Not Found Plugin #{target}"
    end
    def self.require_rb(target)
      require "#{RbFileLauncher.rb_file(target).to_s}"
    end
  end
end

