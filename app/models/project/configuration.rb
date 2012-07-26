class Project
  class Configuration
    attr_accessor :frequency, :ruby, :rake_task, :timeout, :command, :nice, :group, :use_bundle_exec, :bundler_options
    attr_reader :environment_variables, :build_completion_callbacks, :build_failure_callbacks, :build_fixed_callbacks, :build_success_callbacks

    NO_TIMEOUT = Object.new

    def initialize
      @frequency = 20
      @ruby = ruby_version
      @rake_task = :default
      @environment_variables = {}
      @build_completion_callbacks = []
      @build_failure_callbacks = []
      @build_success_callbacks = []
      @build_fixed_callbacks = []
      @timeout = 10.minutes
      @command = nil
      @nice = 0
      @group = 'default'
      @use_bundle_exec = false
      @bundler_options = ''
    end

    def ruby_version
      if Environment.ruby_engine == 'ruby'
        "#{Environment.ruby_version}-p#{Environment.ruby_patchlevel}"
      elsif Environment.ruby_engine == 'jruby'
        "jruby-#{Environment.jruby_version}"
      else
        Environment.ruby_version
      end
    end

    def environment_variables=(new_variables)
      @environment_variables.merge!(new_variables)
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

    def on_build_fixed(&callback_block)
      build_fixed_callbacks << callback_block
    end

    def on_build_success(&callback_block)
      build_success_callbacks << callback_block
    end
  end
end
