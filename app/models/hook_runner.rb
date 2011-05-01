class HookRunner
  def initialize(hooks)
    @hooks = hooks
  end

  def execute(build, project)
    execute_hook(@hooks, build, project)
  end

  private
  def execute_hook(hook, build, project)
    hook.execute(build, project) if hook.respond_to? :execute
    hook.call(build, project) if hook.is_a? Proc
    hook.each { |h| execute_hook(h, build, project) } if hook.is_a? Enumerable
  end
end
