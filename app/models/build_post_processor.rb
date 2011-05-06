class BuildPostProcessor
  def initialize(configuration)
    @callbacks = configuration.build_completion_callbacks
  end

  def execute(build, project)
    execute_hook(@callbacks, build, project)
  end

  private
  def execute_hook(callbacks, build, project)
    callbacks.each { |h| h.call(build, project) }
  end
end
