# -*-mode: ruby; coding: utf-8 -*-

require 'sys/proctable'

module Nand
  module ProcOperation
    def pid_filename( name ); ".nand_#{name}.pid" end
    def ps(pid);   Sys::ProcTable.ps(pid)  end

    def running_ps?(ps, name = nil)
      ps.cmdline =~ /#{$PROGRAM_NAME}/ and ps.cmdline =~/start/ and ( name.nil? or cmdline.include? name.to_s)
    end
    def running_with?(pid, name)
      proc = ps(pid)
      !proc.nil? and running_ps?(proc)
    end
    def pid_from_pidfile(file)
      raise "File Not Found #{file}"    unless FileTest.exist? file
      raise "File Not Readable #{file}" unless FileTest.readable? file
      File.open(file, "r"){|fs| fs.read }.strip.to_i
    end
    def name_from_pidfile(file)
      File.basename(file).to_s.scan(/^\.nand_(\S+)\.pid$/).flatten.first
    end
    def running_in(dir, pattern = nil)
      pattern ||= "*"
      Dir.glob(dir.join(pid_filename(pattern))).
        map{|f|[pid_from_pidfile(f), name_from_pidfile(f)]}.
        map { |pid, name| Daemon.new(dir, name, :uid => ps(pid).euid)}
    end
    def all_runnings
      runnings = Sys::ProcTable.ps.select{ |ps| running_ps?(ps) }
      dirs = runnings.map do |run|
        boot_dir = run.environ["PWD"]
        run_dir = run.cmdline.scan(/--run_dir\s+(\S+)/).flatten.first
        Pathname.new(run_dir || boot_dir)
      end
      dirs.map{ |d| running_in(d) }.flatten
    end
  end
end
