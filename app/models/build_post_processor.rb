class BuildPostProcessor
  attr_reader :configuration

  def initialize(configuration)
    @configuration = configuration
  end

  def execute(build, project, previous_build_status)
    configuration.build_completion_callbacks.each { |callback| callback.call(build, project) }
    configuration.build_failure_callbacks.each{|callback| callback.call(build,project) } if build.status == 'failed'
    configuration.build_success_callbacks.each{|callback| callback.call(build,project) } if build.status == 'passed'
    configuration.red_to_green_callbacks.each{|callback| callback.call(build,project) } if build.status == 'passed' && previous_build_status == 'failed'
  end
end
