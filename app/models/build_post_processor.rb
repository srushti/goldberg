class BuildPostProcessor
  attr_reader :configuration

  def initialize(configuration)
    @configuration = configuration
  end

  def execute(build, previous_build_status)
    configuration.build_completion_callbacks.each { |callback| callback.call(build) }
    configuration.build_failure_callbacks.each{|callback| callback.call(build) } if build.status == 'failed'
    configuration.build_success_callbacks.each{|callback| callback.call(build) } if build.status == 'passed'
    configuration.red_to_green_callbacks.each{|callback| callback.call(build) } if build.status == 'passed' && previous_build_status == 'failed'
  end
end
