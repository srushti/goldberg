require File.join(File.dirname(__FILE__), 'project')

module Goldberg
  class Init
    def run
      send(Environment.argv[0]) if Environment.argv.size > 0
      if Environment.argv.size == 0
        Environment.puts "You did not pass any command."
        Environment.puts "Valid commands are add, remove, list & start."
      end
    end

    def add
      Project.add(:url => Environment.argv[1], :name => Environment.argv[2])
    end

    def remove
      Project.remove(Environment.argv[1])
    end

    def list
      Project.all.map(&:name).each{|name| Environment.puts name}
    end

    def start
      while true
        Project.all.each do |p|
          if p.update
            p.build
          end
        end
        Environment.sleep(20)
      end
    end
  end
end
