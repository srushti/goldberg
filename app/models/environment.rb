module Environment
  class << self
    delegate :expand_path, :exist?, :directory?, to: File

    def stdin
      STDIN
    end

    def argv
      ARGV
    end

    [:sleep, :exec, :trap].each do |method_name|
      define_method method_name do |*args|
        super(*args)
      end
    end

    def write_file(path, text)
      File.open(path, 'w'){|f| f.write text}
    end

    def read_file(path)
      result = ''
      f = File.open(path, "r") do |f|
        f.each_line { |line| result << line }
      end
      result
    end

    def now
      Time.now
    end

    def file_exist?(path)
      File.exist?(path)
    end

    def ruby_engine
      const_defined?('RUBY_ENGINE') ? RUBY_ENGINE : ''
    end

    def ruby_version
      RUBY_VERSION
    end

    ['RUBY_PATCHLEVEL', 'JRUBY_VERSION'].each do |constant|
      if const_defined?(constant)
        define_method constant.downcase do
          eval constant
        end
      end
    end

    def dir_entries(*args)
      Dir.entries(*args)
    end
  end
end
