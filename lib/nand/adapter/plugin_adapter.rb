# -*-mode: ruby; coding: utf-8 -*-

require 'nand/plugin'
require 'nand/adapter/rb_adapter'

module Nand
  class PluginAdapter < RbAdapter
    def self.require_rb(target)
      require "#{target}/nand/plugin"
    end
    def self.connectable?( target, io, opts )
      specs = Gem::Specification.find_all do |s|
        s.name =~/^(nand-)*#{target}$/ and s.dependencies.find{ |d| d.name == "nand" }
      end
      raise "Not Found #{target} in Installed gems" if specs.empty?
      raise "Target name #{target} is Not Uniq for installed gem" if 1 < specs.size
      require_rb(specs.first.name)
      true
    rescue LoadError => e
      io.puts "\t- " + e.message
      false
    rescue => e
      io.puts "\t- " + e.message
      false
    end
  end
end

