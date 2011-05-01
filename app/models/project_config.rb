class ProjectConfig
  KEYS = [:frequency, :ruby, :rake_task]
  attr_accessor :frequency, :ruby, :rake_task, :environment_variables

  def initialize
    @frequency = 20
    @ruby = RUBY_VERSION
    @rake_task = :default
    @environment_variables = {}
  end

  def environment_string
    @environment_variables.each_pair.map { |k, v| "#{k}=#{v}" }.join(" ")
  end
end
