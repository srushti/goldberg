require "fileutils"

class Init
  def add(url, name, branch)
    if Project.add(:url => url, :name => name, :branch => branch)
      Rails.logger.info "#{name} successfully added."
    else
      Rails.logger.info "There was problem adding the project."
    end
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
