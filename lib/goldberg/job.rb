module Goldberg
  class Job
    def self.add(options)
      puts "url #{options[:url]}, with name #{options[:name]}"
    end
  end
end
