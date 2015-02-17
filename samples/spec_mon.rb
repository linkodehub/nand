# -*-mode: ruby; coding: utf-8 -*-

require 'pathname'
require 'fssm'
require 'nand/plugin'

class SpecMon
  extend Plugin
  def self.executor(*argv)
    top_dir  = Pathname.new(argv.shift || Dir.pwd).expand_path
    lib_dir  = top_dir.join("lib")
    spec_dir = top_dir.join("spec")

    [top_dir, lib_dir, spec_dir].each do |dir|
      raise "Not Found Directory #{dir}" unless dir.exist?
      raise "Not Directory #{dir}" unless dir.directory?
    end

    raise "Not Readable Directory #{lib_dir}" unless lib_dir.readable?
    raise "Not Writable Directory #{spec_dir}" unless spec_dir.writable?
    new(lib_dir, spec_dir)
  end
  attr_reader :monitoring_dir, :spec_dir
  def initialize( monitoring_dir, spec_dir )
    @monitoring_dir = Pathname.new(monitoring_dir).expand_path
    @spec_dir = Pathname.new(spec_dir).expand_path
  end
  def monitor
    FSSM.monitor(monitoring_dir, "**/*") do
      create do |dir, file|
        if file =~/\.rb$/
          dist_dir = Pathname.new(dir.gsub(/#{lib_dir.to_s}/, spec_dir.to_s))
          dist_dir.mkpath unless dist_dir.exist?
          spec = dist_dir.join(file.gsub(/\.rb/, "_spec.rb"))
          unless spec.exist?
            File.open(spec, "w") do |fs|
              code = <<-END_SPEC
# -*-mode: ruby; coding: utf-8 -*-
require 'spec_helper'
require '#{file}'

describe "#{file} specification" do
  it "Not Specify"
end

                    END_SPEC
              fs.puts code
            end
          end
        end
      end
    end
  end
  alias :exec :monitor
end

