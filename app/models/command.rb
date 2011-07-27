class Command
  attr_reader :cmd
  def initialize(cmd)
    @cmd = cmd
  end

  def execute_with_output
    Goldberg.logger.info("Executing with output: #{@cmd}")
    `#{@cmd}`
  end
  
  def execute
    command_to_exec = %{/usr/bin/env bash -c "#{@cmd.gsub(/"/, '\"')}"}
    Goldberg.logger.info "Executing #{command_to_exec}"
    if block_given?
      yield execute_with_output(command_to_exec), $?.success?
      $?.success?
    else
      Kernel.system(command_to_exec)
    end
  end

  def fork
    command = %{/usr/bin/env bash -c "#{@cmd.gsub(/"/, '\"')}"}
    Goldberg.logger.info "Forking: #{command}"
    @process = ChildProcess.build(command)
    @process.start
  end

  def running?
    @process.alive?
  end

  def kill
    @process.stop
  end
  
  def pid
    @process.pid
  end
  
  def renice!(relative_priority)
    Environment.system("renice #{relative_priority} #{@process.pid}")
  end
  
  def success?
    @process.exit_code == 0
  end
end
