# -*-mode: ruby; coding: utf-8 -*-

module Nand
  module Plugin
    def executor(*argv) ; raise "Not Implemented #{__method__} in #{self}"  end
    def self.extended(klass)
      raise "Already Registered Name #{klass.name}" if extended_class_map.include? klass.name
      extended_class_map[klass.name] = klass
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

