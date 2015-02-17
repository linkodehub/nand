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
    puts "Monitoring #{lib_dir} and Generate to #{spec_dir}"
    new(lib_dir, spec_dir)
  end
  attr_reader :monitoring_dir, :spec_dir
  def initialize( monitoring_dir, spec_dir )
    @monitoring_dir = Pathname.new(monitoring_dir).expand_path
    @spec_dir = Pathname.new(spec_dir).expand_path
  end
  def monitor
    spec_dir = @spec_dir
    FSSM.monitor(@monitoring_dir, "**/*") do
      create do |dir, file|
        if file =~/\.rb$/
          puts "Created Ruby File #{file} in #{dir}"
          spec = spec_dir.join(file.gsub(/\.rb$/, "_spec.rb"))
          puts "Generate Spec file  #{spec}"
          unless spec.dirname.exist?
            puts "Not Found Dist Path #{spec.dirname}, mkpath!"
            FileUtils.mkdir_p(spec.dirname, :mode => 0755)
          end
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
            if spec.exist?
              puts "Success Genrated #{spec}"
            else
              puts "Failed Genrated #{spec}"
            end
          end
        end
      end
    end
  end
  alias :exec :monitor
end

