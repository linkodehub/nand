# -*-mode: ruby; coding: utf-8 -*-

require 'nand/launcher/shell_launcher'

module Nand
  module Launcher
    class ExecutableFileLauncher < ShellLauncher
      def self.launchable?(target, io, opts)
        file = exec_file(target)
        raise "Not Found #{file.to_s}"  unless file.exist?
        raise "Not Executable #{file.to_s}" unless file.executable?
        true
      rescue => e
        io.puts "\t- " + e.message
        false
      end
      def self.load(target, opts = {}, *argv)
        file = exec_file(target)
        new(target, opts, *argv)
      end
      def self.exec_file(target)
        Pathname.new(target).expand_path
      end
      attr_reader :name
      def initialize(target, opts, *argv)
        super(target, opts, *argv)
        @file = self.class.exec_file(target)
        @name = opts[:name] || @file.basename.to_s
      end
      def cmd; "#{@file} #{@argv.join(" ")}" end
    end
  end
end


