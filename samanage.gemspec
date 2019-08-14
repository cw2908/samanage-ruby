# frozen_string_literal: true

$:.push File.expand_path("../lib", __FILE__)
require "samanage"

Gem::Specification.new do |s|
  s.name                    = "samanage"
  s.version                 =  Samanage::VERSION
  s.date                    =  Date.today.strftime("%Y-%m-%d")
  s.summary                 = "Samanage Ruby Gem"
  s.description             = "Connect to Samanage using Ruby!"
  s.authors                 = ["Chris Walls"]
  s.email                   = "cwalls2908@gmail.com"
  s.files                   = `git ls-files`.split("\n")
  s.homepage                = "https://github.com/cw2908/samanage-ruby"
  s.license                 = "MIT"
  s.require_paths           = ["lib"]
  s.required_ruby_version   = ">= 2.3"
  s.add_development_dependency "httparty", ["0.16.4"]
  s.add_runtime_dependency "httparty", ["0.16.4"]
end
