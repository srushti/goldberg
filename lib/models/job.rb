require 'git'
require File.join(File.dirname(__FILE__), 'paths')

class Job
  def self.add(options)
    Git.clone(options[:url], options[:name], :path => Paths.projects)
  end
end
