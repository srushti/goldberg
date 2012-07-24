task :ci => [:setup_test_env, :'db:drop', :'db:migrate', :spec, :copy_coverage_report]

task :setup_test_env do
  RAILS_ENV = 'test'
end

task :copy_coverage_report do
  FileUtils.cp_r('coverage', ENV['BUILD_ARTEFACTS'], :verbose => true) if ENV['BUILD_ARTEFACTS'].present?
end
