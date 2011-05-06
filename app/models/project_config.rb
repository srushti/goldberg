class ProjectConfig
  attr_accessor :frequency, :ruby, :rake_task, :environment_variables, :timeout
  attr_reader :build_completion_callbacks, :build_failure_callbacks, :red_to_green_callbacks

  def initialize
    @frequency = 20
    @ruby = RUBY_VERSION
    @rake_task = :default
    @environment_variables = {}
    @build_completion_callbacks = []
    @build_failure_callbacks = []
    @red_to_green_callbacks = []
    @timeout = 10.minutes
  end

  def environment_string
    @environment_variables.each_pair.map { |k, v| "#{k}=#{v}" }.join(" ")
  end

  def on_build_completion(&callback_block)
    build_completion_callbacks << callback_block
  end

  def on_build_failure(&callback_block)
    build_failure_callbacks << callback_block
  end

  def on_red_to_green(&callback_block)
    red_to_green_callbacks << callback_block
  end
end
