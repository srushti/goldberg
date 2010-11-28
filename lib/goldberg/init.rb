module Goldberg
  class Init
    def run
      puts "You tried to run with #{ARGV}"
    end

    def add
      Job.add(:url => ARGV[0], :name => ARGV[1])
    end
  end
end
