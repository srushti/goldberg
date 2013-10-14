require "fileutils"

class Init
  def add(url, name, branch, scm, env)
    if Project.add(:url => url, :name => name, :branch => branch, :scm => scm, :local_environment_variables => map_env(env))
      Goldberg.logger.info "#{name} successfully added."
    else
      Goldberg.logger.info "There was problem adding the project."
    end
  end

  def remove(name)
    project = Project.find_by_name(name)
    if project
      project.destroy
      Goldberg.logger.info "#{name} successfully removed."
    else
      Goldberg.logger.error "Project #{name} does not exist."
    end
  end

  def list
    Project.all.map(&:name).each { |name| Goldberg.logger.info name }
  end

  def poll
    Project.projects_to_build.each do |p|
      begin
        p.run_build
      rescue Exception => e
        Goldberg.logger.error "Build on project #{p.name} failed because of #{e}"
        Goldberg.logger.error e.backtrace
      end
    end
  end

  def start_poller
    while true
      poll
      Goldberg.logger.info "Sleeping for #{GlobalConfig.frequency} seconds."
      Environment.sleep(GlobalConfig.frequency)
    end
  end

  def map_env(env_string)
    h = {}
    env_string.split(" ").each do |x| 
      k,v = x.split('=')
      h[k] = v
    end
    h
  end
end