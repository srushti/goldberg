require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
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

desc "Start a console"
task :console do
  system "irb -Ilib -r goldberg"
end

desc "Start server at port 3000 in development mode"
task :server do
  system "rackup -E development -p 3000 config.ru"
end

directory('mnt/projects')

require File.expand_path('../lib/goldberg', __FILE__)
desc "Add a repo for Goldberg to monitor"
task :add, [:url, :name] => [ 'mnt/projects' ] do |t, arg|
  puts "Usage 'rake add[<url>,<name>]'" and exit if arg.count < 2
  Goldberg::Project.add(arg)
  puts "#{arg[:name]} successfully added."
end
