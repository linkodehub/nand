# -*-mode: ruby; coding: utf-8 -*-

require 'nand/launcher'

module Nand
  class ShellAdapter
    class ShellLauncher < Launcher
      def cmd; "#{@progname} #{@argv.join(" ")}" end
      def launch
        spawn("#{cmd}", :out => @exec_stdout, :err => @exec_stderr, :in => @exec_stdin)
      end
    end
    def self.connectable?(name)
      require 'mkmf'
      !find_executable0(name).nil?
    end
    def self.connect(name, opts = {}, *argv)
      ShellLauncher.new(name, opts, *argv)
    end
  end
end


