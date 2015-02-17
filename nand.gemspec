# -*-mode: ruby; coding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nand/version'

Gem::Specification.new do |spec|
  spec.name          = "nand"
  spec.version       = Nand::VERSION
  spec.authors       = ["satoyama"]
  spec.email         = ["satoyama@linkode.co.jp"]
  spec.description   = %q{Nand is Nandemo Daemon Tool, Nandemo means everthing.}
  spec.summary       = %q{Nandemo Daemon Tool}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "fssm"

  spec.required_ruby_version = '>=2.0'
  spec.add_dependency "thor"
  spec.add_dependency "sys-proctable"
end
