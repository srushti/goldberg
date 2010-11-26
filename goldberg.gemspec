lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
Gem::Specification.new do |s|  
  s.name        = "goldberg"
  s.version     = "0.0.1"
  s.authors     = ["Srushti Ambekallu"]
  s.email       = ["srushti@c42.in"]
  s.homepage    = "http://c42.in/open_source"
  s.summary     = "CI server with support for pipelines"
 
  s.required_rubygems_version = ">= 1.3.7"
  
  s.files             = Dir.glob("{bin/**/*,lib/**/*.rb}")
  # s.extra_rdoc_files  = ["README.rdoc"]
  s.rdoc_options      = ["--charset=UTF-8"]
  s.require_path      = 'lib'

  s.add_development_dependency "rspec", ["~> 2.0.0.beta.22"]
end
 
