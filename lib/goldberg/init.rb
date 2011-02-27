require File.join(File.dirname(__FILE__), 'project')

module Goldberg
  class Init
    def run
      if Environment.argv.size > 0 && ['add', 'remove', 'list', 'start'].include?(Environment.argv[0])
        send(Environment.argv[0])
      else
        Environment.puts "You did not pass any command."
        Environment.puts "Valid commands are add, remove, list & start."
      end
    end

    def add
      if Environment.argv.size >= 3
        Project.add(:url => Environment.argv[1], :name => Environment.argv[2], :command => Environment.argv[3])
        Environment.puts "#{Environment.argv[2]} successfully added."
      else
        Environment.puts "Usage 'bin/goldberg add <url> <name> [custom_command]'"
      end
    end

    def remove
      if Environment.argv.size == 2
        Project.new(Environment.argv[1]).remove
        Environment.puts "#{Environment.argv[1]} successfully removed."
      else
        Environment.puts "Usage 'bin/goldberg remove <name>'"
      end
    end

    def list
      Project.all.map(&:name).each{|name| Environment.puts name}
    end

    def start
      Environment.puts "This only runs the scheduler. If you want the web app as well please run 'rake server' instead."
      start_poller
    end

    def start_poller
      while true
        Project.all.each do |p|
          p.update do |project|
            Environment.puts "Build #{ project.build ? "passed" : "failed!" }"
          end
        end
        Environment.puts "Sleeping for 20 seconds."
        Environment.sleep(20)
      end
    end
  end
end
