module Environment
  class << self
    def argv
      ARGV
    end

    def system_call_output(command)
      `/usr/bin/env bash -c "#{command.gsub(/"/, '\"')}"`
    end

    def system(command)
      Rails.logger.info "executing #{command}"
      if block_given?
        yield system_call_output(command), $?.success?
        $?.success?
      else
        super(command)
      end
    end
    
    [:sleep, :exec].each do |method_name|
      define_method method_name do |args|
        super(args)
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
  end
end
