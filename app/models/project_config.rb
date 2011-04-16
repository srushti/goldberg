class ProjectConfig
  KEYS = [:frequency, :ruby, :rails_env]
  attr_accessor :frequency, :ruby, :rails_env

  def initialize
    @frequency = 20
    @ruby = RUBY_VERSION
    @rails_env = nil
  end
end
