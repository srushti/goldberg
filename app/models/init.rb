require "fileutils"

class Init
  def add(url, name, branch)
    Project.add(:url => url, :name => name, :branch => branch)
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

  def start(port = 4242)
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
