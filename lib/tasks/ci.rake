task :ci => ['db:migrate', 'spec', 'copy_coverage_report']

task :copy_coverage_report do
  FileUtils.cp_r('coverage/index.html', ENV['BUILD_ARTEFACTS'], :verbose => true)
end
