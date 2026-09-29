# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rdy"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Oliver Kiessler"]
  s.description = "Rdy is a lightweight Ruby wrapper for AWS DynamoDB."
  s.email = "kiessler@inceedo.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/rdy.rb",
    "rdy.gemspec",
    "rdy.sample.yml",
    "test/helper.rb",
    "test/test_rdy.rb"
  ]
  s.homepage = "http://github.com/okiess/rdy"
  s.licenses = ["MIT"]
  s.summary = "Ruby wrapper for AWS DynamoDB"

  s.add_runtime_dependency "aws-sdk", ">= 1.3.6"
  s.add_runtime_dependency "yaml"

  s.add_development_dependency "shoulda"
  s.add_development_dependency "bundler", ">= 2.0"
  s.add_development_dependency "rake", ">= 12.3.3"
  s.add_development_dependency "git", ">= 1.11.0"
  s.add_development_dependency "test-unit", "~> 3.7"
end
