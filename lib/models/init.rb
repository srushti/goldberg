require File.join(File.dirname(__FILE__), 'job')

class Init
  def run
    send(ARGV[0])
  end

  def add
    Job.add(:url => ARGV[1], :name => ARGV[2])
  end
end
