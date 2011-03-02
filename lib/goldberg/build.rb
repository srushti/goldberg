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
      OpenStruct.new(:number => '', :status => 'never run', :version => 'HEAD', :null? => true, :timestamp => nil)
    end

    def initialize(path)
      @path = path
    end

    def number
      File.basename(@path)
    end

    def log
      Environment.read_file(build_log_path)
    end

    def change_list
      File.exist?(change_list_path) ? Environment.read_file(change_list_path) : nil
    end

    def timestamp
      File.ctime(build_status_path)
    end

    %w(build_status change_list build_log build_version).each do |file_name|
      define_method "#{file_name}_path".to_sym do
        File.join(@path, file_name)
      end
    end

    def status
      if File.exist?(build_status_path)
        Environment.read_file(build_status_path) == 'true' ? 'passed' : 'failed'
      else
        nil
      end
    end

    def version
      File.exist?(build_version_path) ? Environment.read_file(build_version_path) : nil
    end

    def <=>(other)
      path_comparison = build_log_path <=> other.build_log_path
      if path_comparison != 0
        path_comparison
      else
        number.to_i <=> other.number.to_i
      end
    end
  end
end
