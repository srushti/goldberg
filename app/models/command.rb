class Command
  attr_reader :cmd, :start_time

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
    @start_time = DateTime.now
    command = %{/usr/bin/env bash -c "#{@cmd.gsub(/"/, '\"')}"}
    Goldberg.logger.info "Forking: #{command}"
    @process = ChildProcess.build(command)
    @process.start
  end

  def running?
    @process.alive?
  end

  def finished?
    !running?
  end

  def stop
    @process.stop
  end

  def stop_tree(pid_to_be_killed = pid)
    child_parent_processes = `ps -eo pid,ppid | grep #{pid_to_be_killed}`
    child_parent_processes = child_parent_processes.split("\n").map{|child_and_parent| child_and_parent.strip.gsub(/\s+/, " ").split(" ")}
    child_parent_processes.each do |child, parent|
      if parent == pid_to_be_killed
        stop_tree(child)
      end
    end

    system "kill -INT #{pid}"
  end

  def stopped?
    @process.exited?
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
