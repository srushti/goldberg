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

    def remove
      FileUtils.rm_rf(path)
    end

    def checkout(url)
      FileUtils.mkdir_p(File.join(Paths.projects, name))
      if !Environment.system("git clone #{url} #{File.join(Paths.projects, name, 'code')}")
        remove
      end
    rescue
      remove
      raise
    end

    def build_anyway?
      !File.exist?(build_status_path) || !File.exist?("#{build_log_path}") || File.exist?(force_build_path)
    end

    def update
      @logger.info "Checking #{name}"
      if !Environment.system_call_output("cd #{code_path} ; git pull").include?('Already up-to-date.') || build_anyway?
        yield self
      end
    rescue Exception => e
      @logger.error e
    end

    ['build_status', 'force_build', 'build_log', 'code'].each do |relative_path|
      define_method "#{relative_path}_path".to_sym do
        path(relative_path)
      end
    end

    def path(extra = '')
      File.join(Paths.projects, @name, extra)
    end

    def build(task = :default)
      @logger.info "Building #{name}"
      Environment.system("cd #{code_path} ; rake #{task.to_s} > #{build_log_path}").tap do |result|
        @logger.info "Build status #{result}"
        Environment.write_file(build_status_path, result)
        File.delete(force_build_path) if File.exist?(force_build_path)
      end
    end

    def self.all
      (Dir.entries(Paths.projects) - ['.', '..']).select{|entry| File.directory?(File.join(Paths.projects, entry))}.map{|entry| Project.new(entry)}
    end

    def status
      if File.exist?(build_status_path)
        Environment.read_file(build_status_path)[0] == 'true'
      else
        nil
      end
    end

    def status_en
      status ? "passed" : "failed"
    end

    def id
      name.hash.abs
    end
    
    def build_log
      Environment.read_file("#{build_log_path}")
    end

    def force_build
      Environment.write_file(force_build_path, '')
    end
  end
end

