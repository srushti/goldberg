require File.join(File.dirname(__FILE__), 'project')

module Goldberg
  class Init
    def run
      send(CommandLine.argv[0])
    end

    def add
      Project.add(:url => CommandLine.argv[1], :name => CommandLine.argv[2])
    end
  end
end