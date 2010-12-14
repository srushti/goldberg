lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'goldberg/version'

Gem::Specification.new do |s|  
  s.name        = "goldberg"
  s.version     = Goldberg::VERSION::STRING
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

  s.add_development_dependency "rspec", ["~> 2.0.0"]
  s.add_development_dependency "rcov", ["~> 0.9.9"]
  s.add_development_dependency "rack-test", ["~> 0.5.0"]
  s.add_development_dependency "ruby-debug19"

  s.add_runtime_dependency "sinatra", ["~> 1.1.0"]
  s.add_runtime_dependency "sinatra_more", ["~> 0.3.40"]
end
