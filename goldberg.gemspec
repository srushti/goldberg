lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'goldberg/version'

Gem::Specification.new do |s|
  s.name        = "goldberg"
  s.version     = Version::STRING
  s.authors     = ["Srushti Ambekallu"]
  s.email       = ["srushti@ambekallu.com"]
  s.homepage    = "http://goldberg.ambekallu.com"
  s.summary     = "Goldberg is a CI server. With pipelines!"
  s.description = "Goldberg is a CI server built in Ruby with support for pipelines and distributed builds"
  s.rubyforge_project = "goldbergci"

  s.required_rubygems_version = ">= 1.3.7"

  s.files             = Dir.glob("{bin/**/*,lib/**/*.rb}") + %w(README.rdoc CHANGELOG LICENCE)
  s.extra_rdoc_files  = ["README.rdoc"]
  s.rdoc_options      = ["--charset=UTF-8"]
  s.executables       = ['goldberg']
  s.require_path      = 'lib'
end
