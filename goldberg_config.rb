Project.configure do |config|
  config.group = 'c42'
  config.rake_task = 'ci'
  config.use_bundle_exec = true
end
