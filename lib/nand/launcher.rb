# -*-mode: ruby; coding: utf-8 -*-

require 'pathname'

module Nand
  class Launcher
    attr_reader :execname
    def initialize(target, opts, *argv)
      @progname    = target
      @execname    = opts[:name] || File.basename(target)
      @exec_stdout = opts[:out]  || "/dev/null"
      @exec_stderr = opts[:err]  || "/dev/null"
      @exec_stdin  = opts[:in]   || "/dev/null"
      @argv   = argv
    end
    def launch; end
    def ready?
      [@exec_stdout, @exec_stderr].each do |out|
        next if out.is_a? IO
        path = Pathname.new(out)
        raise "Illegal Output File #{path.to_s}" unless (path.exist? and path.writable?) or
          (!path.exist? and path.dirname.writable?)
      end
      return true if @exec_stdin.is_a? IO
      path = Pathname.new(@exec_stdin)
      raise "Illegal Input File #{@exec_stdin.to_s}" unless path.exist? and path.readable?
      true
    end
  end
end
