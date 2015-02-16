# -*-mode: ruby; coding: utf-8 -*-

module Nand
  module Plugin
    def plugin_name; self.name end

    def executor(*argv) ; raise "Not Implemented #{__method__} in #{self}"  end
    def self.extended(klass)
      raise "Already Registered Name #{klass.plugin_name}" if extended_class_map.include? klass.plugin_name
      extended_class_map[klass.plugin_name] = klass
    end
    def self.plugin!( name, *argv )
      raise "Unregisterd #{name}" unless extended_class_map.include? name
      extended_class_map[name].executor(*argv)
    end
    private
    def self.extended_class_map
      @@extended_class_map ||= {}
    end
  end
end

