require File.join(File.dirname(__FILE__), 'project')

module Goldberg
  class Init
    def run
      send(Environment.argv[0]) if Environment.argv.size > 0
    end

    def add
      Project.add(:url => Environment.argv[1], :name => Environment.argv[2])
    end

    def start
      while true
        Project.all.each do |p|
          if p.update
            p.build
          end
        end
        sleep(5)
      end
    end
  end
end
