# -*-mode: ruby; coding: utf-8 -*-

require 'pathname'
require 'nand/launcher'

module Nand
  class RbAdapter
    class RbFileLauncher < Launcher
      def self.rb_file(name)
        Pathname.new(name).expand_path
      end
      def initialize(name, executor, opts, *argv)
        super(name, opts, *argv)
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
    def self.connectable?( name, *argv )
      return false if name.to_s =~/\.rb$/
      require_rb(name)
      true
    rescue LoadError => e
      false
    rescue
      false
    end
    def self.connect( name, opts, *argv )
      require_rb(name)
      executor = Plugin.plugin!(name, *argv)
      raise "Executor #{name} is Not Emplemented exec Method" unless executor.respond_to?(:exec)
      RbFileLauncher.new(name, executor, opts, *argv)
    rescue LoadError => e
        raise "Not Found Plugin #{name}"
    end
    def self.require_rb(name)
      require "#{rb_file(name)}"
    end
  end
end

