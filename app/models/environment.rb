module Environment
  class << self
    delegate :expand_path, :exist?, :directory?, :to => File

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

    def file_exist?(path)
      File.exist?(path)
    end
  end
end
