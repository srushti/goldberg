require File.join(File.dirname(__FILE__), 'project')

module Goldberg
  class Init
    def run
      if Environment.argv.size > 0
        send(Environment.argv[0])
      else
        Environment.puts "You did not pass any command."
        Environment.puts "Valid commands are add, remove, list & start."
      end
    end

    def add
      if Environment.argv.size == 3
        Project.add(:url => Environment.argv[1], :name => Environment.argv[2])
        Environment.puts "#{Environment.argv[2]} successfully added."
      else
        Environment.puts "Usage 'bin/goldberg add <url> <name>'"
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
      while true
        Project.all.each do |p|
          p.update do |project|
            exit_value = p.build
            build_status = exit_value ? "passed" : "failed"
            Environment.puts "Build #{build_status}!"
          end
          Environment.sleep(20)
        end
      end
    end
  end
end
