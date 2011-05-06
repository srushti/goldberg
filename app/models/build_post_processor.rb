class BuildPostProcessor
  attr_reader :build_completion_callbacks, :build_failure_callbacks, :build_success_callbacks

  def initialize(configuration)
    @build_completion_callbacks = configuration.build_completion_callbacks
    @build_failure_callbacks = configuration.build_failure_callbacks
    @build_success_callbacks = configuration.build_success_callbacks
  end

  def execute(build, project)
    build_completion_callbacks.each { |callback| callback.call(build, project) }
    build_failure_callbacks.each{|callback| callback.call(build,project) } if build.status == 'failed'
    build_success_callbacks.each{|callback| callback.call(build,project) } if build.status == 'passed'
  end
end
