# -*-mode: ruby; coding: utf-8 -*-

require 'nand/plugin'
require 'nand/adapter/rb_adapter'

module Nand
  class PluginAdapter < RbAdapter
    def self.require_rb(name)
      require "#{name}/nand/plugin"
    end
  end
end

