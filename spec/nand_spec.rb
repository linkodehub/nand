require 'spec_helper'

describe Nand do
  it 'should have a version number' do
    expect(Nand::VERSION).to_not be_nil
  end

  describe "string_to_stdio" do
    it '"STDOUT" eval to STDOUT' do
      expect(string_to_stdio("STDOUT")).to eq(STDOUT)
    end
    it '"STDERR" eval to STDERR' do
      expect(string_to_stdio("STDERR")).to eq(STDERR)
    end
    it '"STDOUT" eval to STDIN' do
      expect(string_to_stdio("STDIN")).to eq(STDIN)
    end
  end
  describe "additional_argv" do
    let(:argv){ %w(a b c 100) }
    let(:additional_argv) do
      Nand.additional_argv = argv
      Nand.additional_argv
    end
    it { expect(additional_argv).to eq argv }
    it { expect(additional_argv).to be_frozen }
  end
end
