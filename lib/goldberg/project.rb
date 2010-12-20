require "fileutils"

module Goldberg
  class Project
    attr_reader :url, :name

    def initialize(name)
      @name = name
      @logger = Logger.new
    end

    def self.add(options)
      Project.new(options[:name]).tap do |project|
        project.checkout(options[:url])
      end
    end

    def self.remove(name)
      FileUtils.rm_rf(File.join(Paths.projects, name))
    end

    def checkout(url)
      Git.clone(url, @name, :path => Paths.projects)
    end

    def update
      @logger.info "Updating #{name}"
      g = Git.open(File.join(Paths.projects, @name), :log => @logger)
      fetch_result = g.fetch('origin')
      (!fetch_result.empty?).tap do |fetched_changes|
        g.merge('master', 'origin pull') if fetched_changes
      end
    end

    def build(task = :default)
      @logger.info "Building #{name}"
      Environment.system("cd #{File.join(Paths.projects, @name)} ; rake #{task.to_s}").tap{|result| @logger.info "Build status #{result}"}
    end

    def self.all
      (Dir.entries(Paths.projects) - ['.', '..']).select{|entry| File.directory?(File.join(Paths.projects, entry))}.map{|entry| Project.new(entry)}
    end
  end
end

