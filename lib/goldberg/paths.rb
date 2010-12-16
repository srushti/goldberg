require "fileutils"

module Goldberg
  module Paths
    class << self
      def root
        absolute_path
      end

      def absolute_path(*args)
        File.join(File.dirname(__FILE__), %w(.. ..) + args)
      end

      def projects
        goldberg_path = Env['GOLDBERG_PATH'] || File.join(Env['HOME'], '.goldberg')
        create_if_doesnt_exist(File.join(goldberg_path, 'projects'))
      end

      def create_if_doesnt_exist(path)
        path.tap{|path| FileUtils.mkdir_p(path) if !File.exist?(path)}
      end
    end
  end
end

module Env
  class << self
    def [](variable_name)
      ENV[variable_name]
    end

    def home
      ["HOME"]
    end
  end
end
