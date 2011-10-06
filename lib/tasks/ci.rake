task :ci => ['db:drop', 'db:migrate', 'spec', 'copy_coverage_report']

task :copy_coverage_report do
  FileUtils.cp_r('coverage', ENV['BUILD_ARTEFACTS'] || 'output', :verbose => true)
end
