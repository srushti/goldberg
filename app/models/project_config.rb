class ProjectConfig
  attr_accessor :frequency, :rake_task

  def initialize
    @frequency = 20
    @rake_task = :default
  end
end
