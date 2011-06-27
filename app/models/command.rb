class Command
  def initialize(cmd)
    @cmd = cmd
  end

  def execute
    Environment.system(cmd)
  end

  def execute_async
    @process = ChildProcess.build(%{/usr/bin/env bash -c "#{@cmd.gsub(/"/, '\"')}"})
    @process.start
  end

  def running?
    @process.alive?
  end

  def kill
    @process.send_kill
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
