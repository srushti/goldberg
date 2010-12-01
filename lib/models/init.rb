require File.join(File.dirname(__FILE__), 'project')

class Init
  def run
    send(ARGV[0])
  end

  def add
    Project.add(:url => ARGV[1], :name => ARGV[2])
  end
end
