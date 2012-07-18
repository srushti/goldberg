task :ci => [:setup_test_env, :'db:drop', :'db:migrate', :spec, :copy_coverage_report]

task :setup_test_env do
  ENV['RAILS_ENV'] = 'test'
end

task :copy_coverage_report do
  FileUtils.cp_r('coverage', ENV['BUILD_ARTEFACTS'] || 'output', :verbose => true)
end
