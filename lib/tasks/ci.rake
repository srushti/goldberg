task :ci => ['db:migrate', 'spec:rcov', 'copy_rcov_report']

task :copy_rcov_report do
  FileUtils.mkdir_p(ENV['BUILD_ARTEFACTS']) unless File.exist?(ENV['BUILD_ARTEFACTS'])
  FileUtils.cp_r('coverage', ENV['BUILD_ARTEFACTS'])
end
