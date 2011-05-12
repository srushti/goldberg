class Command
  def initialize(cmd)
    @cmd = cmd
  end

  def execute
    Environment.system(cmd)
  end

  def execute_async
    @pid = Process.spawn(%{/usr/bin/env bash -c "#{@cmd.gsub(/"/, '\"')}"}).tap{|pid| Rails.logger.info("The pid of the build process is #{pid}")}
  end

  def running?
    Process.waitpid(@pid, Process::WNOHANG).nil?
  end

  def kill
    Process.kill('KILL', @pid)
  end

  def self.success?
    ($?).success?
  end
end
