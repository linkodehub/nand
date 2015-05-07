# -*-mode: ruby; coding: utf-8 -*-
require 'spec_helper'
require 'nand/version'

describe "nand/version.rb specification" do
  it "VERSION is defined" do
    expect(Nand::VERSION).not_to be_nil
  end
end

