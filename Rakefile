require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "goldberg"
  gem.email = "srushti@c42.in"
  gem.homepage = "http://c42.in/open_source"
  gem.authors = "Srushti Ambekallu"
  gem.files = Dir.glob("{bin/**/*,lib/**/*.rb}")
  # gem.test_files = FileList["test/*.rb"]
  gem.extra_rdoc_files = ["README"]
end
Jeweler::RubygemsDotOrgTasks.new

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

