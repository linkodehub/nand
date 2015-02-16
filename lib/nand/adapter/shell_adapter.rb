# -*-mode: ruby; coding: utf-8 -*-

require 'nand/launcher'

module Nand
  class ShellAdapter
    class ShellLauncher < Launcher
      def cmd; "#{@progname} #{@argv.join(" ")}" end
      def launch
        spawn("#{cmd}", :out => @exec_stdout, :err => @exec_stderr, :in => @exec_stdin, :pgroup => true)
      end
    end
    def self.connectable?(target, opts)
      require 'mkmf'
      !find_executable0(target).nil?
    end
    def self.connect(target, opts = {}, *argv)
      ShellLauncher.new(target, opts, *argv)
    end
  end
end


