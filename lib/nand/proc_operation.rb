# -*-mode: ruby; coding: utf-8 -*-

require 'sys/proctable'

module Nand
  module ProcOperation
    def pid_filename( name ); ".nand_#{name}.pid" end
    def ps(pid);   Sys::ProcTable.ps(pid)  end

    def running_ps?(ps, name = nil)
      ps.cmdline =~ /#{$PROGRAM_NAME}/ and ps.cmdline =~/start/ and ( name.nil? or ps.cmdline.include? name.to_s)
    end
    def running_with?(pid, name)
      proc = ps(pid)
      !proc.nil? and running_ps?(proc, name)
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
        map{ |pid, name| Daemon.new(dir, name, :uid => ps(pid).euid)}
    end
    def all_runnings
      uid = Process.uid
      runnings = Sys::ProcTable.ps.select{ |ps| running_ps?(ps) and ps.ppid == 1 and (ps.euid == uid or uid == 0)}
      dirs = runnings.map do |run|
        boot_dir = run.environ["PWD"]
        run_dir = run.cmdline.scan(/--run_dir\s+(\S+)/).flatten.first
        Pathname.new(run_dir || boot_dir)
      end.uniq
      daemons = dirs.map{ |d| running_in(d) }.flatten
      unless daemons.size == runnings.size
        unmanageds = runnings.reject{ |ps| daemons.find{|d| d.pid == ps.pid} }.map{ |ps| ps.pid}
        raise "Found Unmanaged Nand Process [#{unmanageds.join(", ")}], Send Signal Yourself"
      end
      daemons
    end
  end
end
