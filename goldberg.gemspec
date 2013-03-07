lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'goldberg/version'

Gem::Specification.new do |s|
  s.name        = "goldberg"
  s.version     = Version::STRING
  s.authors     = ["Sidu Ponnappa", "Niranjan Paranjape", "Srushti Ambekallu"]
  s.email       = ["sidu@c42.in", "niranjan@c42.in", "srushti@c42.in"]
  s.homepage    = "http://c42.in/open_source"
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
