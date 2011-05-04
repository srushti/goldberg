class Command
  def initialize(cmd)
    @cmd = cmd
  end

  def execute
    Environment.system(cmd)
  end

  def execute_async(total_time)
    @io = IO.popen(%{/usr/bin/env bash -c "#{command.gsub(/"/, '\"')}"})
  end

  def running?
    Process.getpriority(Process::PRIO_PROCESS, @io.pid)
    true
  rescue
    false
  end

  def kill
    Process.kill(0, @io.pid)
  end

  def self.success?
    ($?).success?
  end
end
