# -*-mode: ruby; coding: utf-8 -*-

require 'nand/adapter/shell_adapter'
require 'nand/adapter/executable_file_adapter'
require 'nand/adapter/rb_adapter'
require 'nand/adapter/plugin_adapter'


module Nand
  class LauncherFinder
    def self.find(target, opts = {}, *argv)
      adapter = [ExecutableFileAdapter, RbAdapter, PluginAdapter, ShellAdapter].find do |adapter|
        adapter.connectable? target, opts
      end
      raise "Not Found Executable #{target}" if adapter.nil?
      launcher = adapter.connect(target, opts, *argv)
      raise "Not be Ready for #{target} Launcher" unless launcher.ready?
      launcher
    end
  end
end
