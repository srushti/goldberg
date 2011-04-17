class ProjectConfig
  KEYS = [:frequency, :ruby, :rails_env, :rake_task]
  attr_accessor :frequency, :ruby, :rails_env, :rake_task

  def initialize
    @frequency = 20
    @ruby = RUBY_VERSION
    @rails_env = nil
    @rake_task = :default
  end
end
