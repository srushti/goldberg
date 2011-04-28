task :ci => ['db:migrate', 'spec:rcov', 'copy_rcov_report']

task :copy_rcov_report do
  FileUtils.cp_r('coverage/*', ENV['BUILD_ARTEFACTS'], :verbose => true)
end
