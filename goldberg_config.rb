Project.configure do |config|
  config.group = 'c42'
  config.rake_task = 'ci'
  config.use_bundle_exec = true
  config.environment_variables = {'RAILS_ENV' => 'test'}

  config.on_build_completion do |build,notification,previous_build_status|
  end

  config.on_build_success do |build,notification|
  end

  config.on_build_failure do |build,notification|
    notification.from('eng-rt@demandbase.com').to('eng-rt@demandbase.com').with_subject("Build for #{build.project.name} #{build.status}").send
  end

  config.on_build_fixed do |build,notification|
    notification.from('eng-rt@demandbase.com').to('eng-rt@demandbase.com').with_subject("Build for #{build.project.name} #{build.status}").send
  end
end
