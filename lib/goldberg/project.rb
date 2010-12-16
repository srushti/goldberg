module Goldberg
  class Project
    attr_reader :url, :name

    def initialize(name)
      @name = name
    end

    def self.add(options)
      Project.new(options[:name]).tap do |project|
        project.checkout(options[:url])
      end
    end

    def checkout(url)
      Git.clone(url, @name, :path => Paths.projects)
    end

    def update
      g = Git.open(File.join(Paths.projects, @name), :log => Logger.new)
      g.pull
    end

    def self.all
      (Dir.entries(Paths.projects) - ['.', '..']).select{|entry| File.directory?(File.join(Paths.projects, entry))}.map{|entry| Project.new(entry)}
    end
  end
end

