class Command
  def initialize(cmd)
    @cmd = cmd
  end

  def execute
    Environment.system(cmd)
  end

  def execute_async
    @process = ChildProcess.build(%{/usr/bin/env bash -c "#{@cmd.gsub(/"/, '\"')}"})
    Rails.logger.info("The pid of the build process is #{@process.pid}")
    @process.start
  end

  def running?
    @process.alive?
  end

  def kill
    @process.send_kill
  end

  def success?
    @process.exit_code == 0
  end
end
