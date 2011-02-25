module Goldberg
  class Build
    include Comparable

    def self.all(project)
      FileUtils.mkdir_p(project.builds_path) if !File.exist?(project.builds_path)
      (Dir.entries(project.builds_path) - ['.', '..'])
        .map{|entry| File.join(project.builds_path, entry)}
        .select{|entry| File.directory?(entry)}
        .map{|dir_entry| Build.new(dir_entry)}.sort.reverse
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

    def log_path
      File.join(@path, 'build_log')
    end

    def log
      Environment.read_file(log_path)
    end

    def status
      build_status_path = File.join(@path, 'build_status')
      if File.exist?(build_status_path)
        Environment.read_file(build_status_path) == 'true'
      else
        nil
      end
    end

    def version
      build_version_path = File.join(@path, 'build_version')
      Environment.read_file(build_version_path)
    end

    def <=>(other)
      path_comparison = log_path <=> log_path
      if path_comparison != 0
        path_comparison
      else
        number.to_i <=> other.number.to_i
      end
    end
  end
end
