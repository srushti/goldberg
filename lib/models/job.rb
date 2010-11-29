require 'git'
require File.join(File.dirname(__FILE__), 'paths')

class Job
  def self.add(options)
    Git.clone(options[:url], options[:name], :path => File.join(Paths.projects))
    puts "url #{options[:url]}, with name #{options[:name]}"
  end
end
