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
      Project.add(:url => Environment.argv[1], :name => Environment.argv[2])
    end

    def remove
      Project.new(Environment.argv[1]).remove
    end

    def list
      Project.all.map(&:name).each{|name| Environment.puts name}
    end

    def start
      while true
        Project.all.each do |p|
          if p.update
            exit_value = p.build
            build_status = exit_value ? "passed" : "failed"
            Environment.puts "Build #{build_status}!"
          end
        end
        Environment.sleep(20)
      end
    end
  end
end
