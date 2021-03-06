# -*-mode: ruby; coding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nand/version'

Gem::Specification.new do |spec|
  spec.name          = "nand"
  spec.version       = Nand::VERSION
  spec.authors       = ["nstoym"]
  spec.email         = ["nstoym@linkode.co.jp"]
  spec.description   = %q{Nand is a simple CLI tool to make anything daemon by Ruby.}
  spec.summary       = %q{Nandemo Daemon Tool}
  spec.homepage      = "https://github.com/linkodehub/nand"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "fssm"

  spec.required_ruby_version = '>=2.0'
  spec.add_dependency "thor"
  spec.add_dependency "sys-proctable"
end
