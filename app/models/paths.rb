require "fileutils"

module Paths
  class << self
    def pid
      pid_path = create_if_doesnt_exist(File.join(goldberg_path, 'pids'))
      File.join(pid_path, 'goldberg.pid')
    end

    def projects
      create_if_doesnt_exist(File.join(goldberg_path, 'projects'))
    end

    def goldberg_path
      Env['GOLDBERG_PATH'] || File.join(Env['HOME'], '.goldberg')
    end

    def create_if_doesnt_exist(path)
      path.tap{|path| FileUtils.mkdir_p(path) if !File.exist?(path)}
    end
  end
end

