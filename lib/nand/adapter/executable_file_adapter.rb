# -*-mode: ruby; coding: utf-8 -*-

require 'nand/adapter/shell_adapter'

module Nand
  class ExecutableFileAdapter
    class FileLauncher < ShellAdapter::ShellLauncher
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
    def self.connectable?(target, opts)
      file = FileLauncher.exec_file(target)
        file.exist? and file.executable?
    end
    def self.connect(target, opts = {}, *argv)
      file = FileLauncher.exec_file(target)
      raise "Not Found #{file.to_s}"  unless file.exist?
      raise "Not Executable #{file.to_s}" unless file.executable?
      FileLauncher.new(target, opts, *argv)
    end
  end
end


