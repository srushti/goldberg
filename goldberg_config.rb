Project.configure do |config|
  config.group = 'c42'
  config.rake_task = 'ci'
  config.use_bundle_exec = true
  config.environment_variables = { 'RAILS_ENV' => 'test', 'JRUBY_OPTS' => '--1.9' }
end
