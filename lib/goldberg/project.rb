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
      begin
        fetch_result = g.fetch('origin')
        (!fetch_result.empty?).tap do |fetched_changes|
          g.merge('master', 'origin pull') if fetched_changes
        end
      rescue Exception => e
        @logger.error e
      end
    end

    def build_status_file_path
      File.join(Paths.projects, "#{@name}.status")
    end

    def build(task = :default)
      @logger.info "Building #{name}"
      Environment.system("cd #{File.join(Paths.projects, @name)} ; rake #{task.to_s}").tap do |result|
        @logger.info "Build status #{result}"
        Environment.write_file(build_status_file_path, result)
      end
    end

    def self.all
      (Dir.entries(Paths.projects) - ['.', '..']).select{|entry| File.directory?(File.join(Paths.projects, entry))}.map{|entry| Project.new(entry)}
    end

    def status
      if File.exist?(build_status_file_path)
        contents = Environment.read_file(build_status_file_path)
      else
        "unknown"
      end
    end
  end
end

