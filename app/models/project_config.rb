class ProjectConfig
  KEYS = [:frequency, :ruby, :rake_task]
  attr_accessor :frequency, :ruby, :rake_task

  def initialize
    @frequency = 20
    @ruby = RUBY_VERSION
    @rake_task = :default
  end
end
