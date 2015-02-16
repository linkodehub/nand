# -*-mode: ruby; coding: utf-8 -*-

require 'nand/adapter/shell_adapter'

module Nand
  class ExecutableFileAdapter
    class FileLauncher < ShellAdapter::ShellLauncher
      def self.exec_file(name)
        Pathname.new(name).expand_path
      end
      attr_reader :name
      def initialize(name, opts, *argv)
        super(name, opts, *argv)
        @file = self.class.exec_file(name)
        @name = opts[:name] || @file.basename.to_s
      end
      def cmd; "#{@file} #{@argv.join(" ")}" end
    end
    def self.connectable?(name)
      FileLauncher.exec_file(name).exist?
    end
    def self.connect(name, opts = {}, *argv)
      file = FileLauncher.exec_file(name)
      raise "Not Found #{file.to_s}"  unless file.exist?
      raise "Not Executable #{file.to_s}" unless file.executable?
      FileLauncher.new(name, opts, *argv)
    end
  end
end


