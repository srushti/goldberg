require "fileutils"

class Init
  def add(url, name, branch, scm)
    if Project.add(:url => url, :name => name, :branch => branch, :scm => scm)
      Goldberg.logger.info "#{name} successfully added."
    else
      Goldberg.logger.info "There was problem adding the project."
    end
  end

  def add_user(username, project_name, role)
    Goldberg.logger.info "Give role is: #{role}"
    Goldberg.logger.info "RoleType is: #{RoleType.find_by_name(role)}"
    user = User.find_by_login(username) || User.create(:login => username)
    if user && user.roles.create(:role_type => RoleType.find_by_name(role), :project => Project.find_by_name(project_name))
      Goldberg.logger.info "#{username} succesfully added as #{role} to #{project_name}"
    else
      Goldberg.logger.info "User could not be added"
    end
  end

  def users
    users = []
    Role.all.map do |role|
      users << "#{role.user.login} is #{role.role_type.name} of #{role.project.name}"
    end
    Goldberg.logger.info users.join("\n")
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

  def user_roles
    RoleType.all.map(&:name).each {|name| Goldberg.logger.info name}
  end
end
