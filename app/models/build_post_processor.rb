class BuildPostProcessor
  def initialize(callbacks)
    @callbacks = callbacks
  end

  def execute(build, project)
    execute_hook(@callbacks, build, project)
  end

  private
  def execute_hook(callbacks, build, project)
    callbacks.execute(build, project) if callbacks.respond_to? :execute
    callbacks.call(build, project) if callbacks.is_a? Proc
    callbacks.each { |h| execute_hook(h, build, project) } if callbacks.is_a? Enumerable
  end
end
