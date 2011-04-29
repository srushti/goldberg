require "fileutils"

class Init
  def bootstrap
    if RVM.installed?
      Rails.logger.info "It looks like you have RVM installed. We will now add the following settings to your global .rvmrc located at #{Env['HOME']}."
      Rails.logger.info "#{RVM.goldberg_rvmrc_contents}\n(Y/n)"
      if ['yes', 'y'].include?(Environment.STDIN.gets.chomp.downcase)
        RVM.write_goldberg_rvmrc_contents
      else
        Rails.logger.info "Aborting"
      end
    else
      Rails.logger.info "RVM doesn't seem to be installed!\nYou can use Goldberg but all projects will be run on the default ruby: #{RUBY_ENGINE} #{RUBY_VERSION}.\nIf you wish to run on different rubies install rvm and run this 'bin/goldberg bootstrap' again."
    end
  end

  def add(url, name, branch, command = nil)
    Project.add(:url => url, :name => name, :command => command, :branch => branch)
    Rails.logger.info "#{name} successfully added."
  end

  def remove(name)
    project = Project.find_by_name(name)
    if project
      project.destroy
      Rails.logger.info "#{name} successfully removed."
    else
      Rails.logger.error "Project #{name} does not exist."
    end
  end

  def list
    Project.all.map(&:name).each { |name| Rails.logger.info name }
  end

  def start(port = 3000)
    if !File.exist?(Paths.pid)
      Environment.exec "rackup -p #{port} -D -P #{Paths.pid} #{File.join(File.dirname(__FILE__), '..', '..', 'config.ru')}"
    else
      Rails.logger.info "Goldberg already appears to be running. Please run 'bin/goldberg stop' or delete the existing pid file."
    end
  end

  def stop
    if File.exist?(Paths.pid)
      Environment.exec "kill `cat #{Paths.pid}`"
      FileUtils.rm(Paths.pid)
    else
      Rails.logger.info "Goldberg does not appear to be running."
    end
  end

  def poll
    Project.projects_to_build.each do |p|
      begin
        p.run_build
      rescue Exception => e
        Rails.logger.error "Build on project #{p.name} failed because of #{e}"
        Rails.logger.error e.backtrace
      end
    end
  end

  def start_poller
    while true
      poll
      Rails.logger.info "Sleeping for #{GlobalConfig.frequency} seconds."
      Environment.sleep(GlobalConfig.frequency)
    end
  end
end
