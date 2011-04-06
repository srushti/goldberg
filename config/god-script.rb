GOLDBERG_ROOT  = File.dirname(File.dirname(__FILE__))

God.watch do |w|
  w.name        = "poller"
  w.interval    = 10.seconds
  w.start       = "cd #{GOLDBERG_ROOT} && ./bin/goldberg start_poller >> ./log/poller.log"
  w.start_grace = 10.seconds

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end