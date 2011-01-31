# -*- encoding: utf-8 -*-
require File.expand_path("../config/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "stories"
  s.version     = Stories::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/stories"
  s.summary     = "The Story Manager blahdi blah blah."
  s.description = "The Story Manager blahdi blah blah."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "stories"

  s.add_development_dependency "bundler", ">= 1.0.0"
  
  Bundler.definition.dependencies.select { |d| d.type == :runtime }.each do |d|
    s.add_runtime_dependency d.name, d.requirement
  end

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end