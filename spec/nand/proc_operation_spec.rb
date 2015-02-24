# -*-mode: ruby; coding: utf-8 -*-
require 'spec_helper'
require 'nand/proc_operation'
require 'pathname'

include ProcOperation

describe "nand/proc_operation.rb specification" do
  before(:all) do
    @work_dir = Pathname.new("/tmp")
  end
  context :pid_filename do
    it { expect(pid_filename("abc")).to eq ".nand_abc.pid" }
  end
  context :name_from_pidfile do
    before(:all){ @pidfile = @work_dir.join(".nand_abc.pid"); system("touch #{@pidfile}")}
    after(:all){ @pidfile.delete if @pidfile.exist? }
    it { expect(name_from_pidfile(@pidfile)).to eq "abc" }
  end
  context :ps do
    let(:proc){ps(Process.pid)}
    it { expect(proc).to_not be_nil }
    it { expect(proc).to be_is_a Struct::ProcTableStruct }
    it { expect(proc.cmdline).to be_include "rspec" }
  end
  context :pid_from_pidfile do
    before(:all) do
      @pidfile = @work_dir.join(".nand_abc.pid")
      @pid = 12345
      File.open(@pidfile, "w"){|fs| fs.puts @pid }
    end
    after(:all){ @pidfile.delete if @pidfile.exist? }
    it { expect(pid_from_pidfile(@pidfile)).to eq @pid}
  end
  context :running_in do
  end
  context :running_ps? do
  end
  context :running_with? do
  end
  context :all_runnings do
  end
end

