require "fileutils"

module Paths
  class << self
    def projects
      goldberg_path = Env['GOLDBERG_PATH'] || File.join(Env['HOME'], '.goldberg')
      create_if_doesnt_exist(File.join(goldberg_path, 'projects'))
    end

    def create_if_doesnt_exist(path)
      path.tap{|path| FileUtils.mkdir_p(path) if !File.exist?(path)}
    end
  end
end

