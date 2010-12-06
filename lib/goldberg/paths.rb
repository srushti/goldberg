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
        absolute_path("projects")
      end
    end
  end
end