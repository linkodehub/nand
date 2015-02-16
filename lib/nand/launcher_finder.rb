# -*-mode: ruby; coding: utf-8 -*-

require 'nand/adapter/shell_adapter'
require 'nand/adapter/executable_file_adapter'
require 'nand/adapter/plugin_adapter'


module Nand
  class LauncherFinder
    def self.find(name, opts = {}, *argv)
      adapter = [ExecutableFileAdapter, PluginAdapter, ShellAdapter].find do |adapter|
        adapter.connectable? name
      end
      raise "Not Found Executable #{name}" if adapter.nil?
      launcher = adapter.connect(name, opts, *argv)
      raise "Not be Ready for #{name} Launcher" unless launcher.ready?
      launcher
    end
  end
end
