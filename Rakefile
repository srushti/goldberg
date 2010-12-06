require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |spec|
  spec.libs << 'spec'
  spec.pattern = 'spec/**/spec*.rb'
  spec.verbose = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "something-new #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

