class Command
  def initialize(cmd)
    @cmd = cmd
  end

  def execute
    Environment.system(cmd)
  end

  def execute_async(total_time)
    @pid = IO.popen(%{/usr/bin/env bash -c "#{command.gsub(/"/, '\"')}"}).pid
  end

  def running?
    Process.getpriority(Process::PRIO_PROCESS, @pid)
    true
  rescue
    false
  end

  def kill
    Process.kill(0, @pid)
  end

  def self.success?
    ($?).success?
  end
end
