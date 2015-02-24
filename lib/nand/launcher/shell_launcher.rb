# -*-mode: ruby; coding: utf-8 -*-

require 'nand/launcher'

module Nand
  module Launcher
    class ShellLauncher < Base
      def self.launchable?(target, io, opts)
        require 'mkmf'
        raise "Not Executable #{target}" if find_executable0(target).nil?
        true
      rescue => e
        io.puts "\t- " + e.message
        false
      end
      def self.load(target, opts = {}, *argv)
        new(target, opts, *argv)
      end
      def cmd; "#{@progname} #{@argv.join(" ")}" end
      def launch
        spawn("#{cmd}", :out => @exec_stdout, :err => @exec_stderr, :in => @exec_stdin, :pgroup => true)
      end
    end
  end
end
