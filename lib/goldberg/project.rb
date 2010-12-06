module Goldberg
  class Project
    attr_reader :url, :name

    def initialize(url, name)
      @url = url
      @name = name
    end

    def self.add(options)
      Project.new(options[:url], options[:name]).tap do |project|
        project.checkout
      end
    end

    def checkout
      Git.clone(@url, @name, :path => Paths.projects)
    end
  end
end