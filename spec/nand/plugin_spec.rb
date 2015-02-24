# -*-mode: ruby; coding: utf-8 -*-
require 'spec_helper'
require 'nand/plugin'

describe Nand::Plugin do
  before(:all) do
    class Hoge ; extend Plugin end
    class Fuga ; extend Plugin ; def self.executor(*argv); nil end end
  end
  it { expect(Hoge).to be_respond_to :executor }
  it :plugin_name do
    expect(Hoge.plugin_name).to eq Hoge.to_s
  end
  it "implemented executor"  do
    expect(Fuga.executor).to be_nil
  end
  it "not implemented executor"  do
    expect{Hoge.executor}.to raise_error RuntimeError
  end
  it "#plugin!" do expect(Plugin.plugin!("Fuga")).to be_nil end
end

