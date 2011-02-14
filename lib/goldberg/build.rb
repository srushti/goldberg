module Goldberg
  class Build
    def self.all(project)
      FileUtils.mkdir_p(project.builds_path) if !File.exist?(project.builds_path)
      (Dir.entries(project.builds_path) - ['.', '..']).map{|entry| File.join(project.builds_path, entry)}.select{|entry| File.directory?(entry)}.map{|dir_entry| Build.new(dir_entry)}
    end

    def self.null
      OpenStruct.new(:number => '', :status => 'never run')
    end

    def initialize(path)
      @path = path
    end

    def number
      File.basename(@path)
    end

    def status
      build_status_path = File.join(@path, 'build_status')
      if File.exist?(build_status_path)
        Environment.read_file(build_status_path) == 'true' ? 'passed' : 'failed'
      else
        nil
      end
    end
  end
end
