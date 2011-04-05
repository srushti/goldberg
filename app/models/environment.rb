module Environment
  class << self
    def argv
      ARGV
    end

    def system_call_output(command)
      Rails.logger.info("System call output: #{command}")
      `#{command}`
    end

    def system(command)
      command_to_exec = %{/usr/bin/env zsh -c "#{command.gsub(/"/, '\"')}"}
      Rails.logger.info "executing #{command_to_exec}"
      if block_given?
        yield system_call_output(command_to_exec), $?.success?
        $?.success?
      else
        super(command_to_exec)
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
