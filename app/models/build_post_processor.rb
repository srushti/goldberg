class BuildPostProcessor
  attr_reader :build_completion_callbacks, :build_failure_callbacks, :build_success_callbacks, :red_to_green_callbacks

  def initialize(configuration)
    @build_completion_callbacks = configuration.build_completion_callbacks
    @build_failure_callbacks = configuration.build_failure_callbacks
    @build_success_callbacks = configuration.build_success_callbacks
    @red_to_green_callbacks = configuration.red_to_green_callbacks
  end

  def execute(build, project, previous_build_status)
    build_completion_callbacks.each { |callback| callback.call(build, project) }
    build_failure_callbacks.each{|callback| callback.call(build,project) } if build.status == 'failed'
    build_success_callbacks.each{|callback| callback.call(build,project) } if build.status == 'passed'
    red_to_green_callbacks.each{|callback| callback.call(build,project) } if build.status == 'passed' && previous_build_status == 'failed'
  end
end
