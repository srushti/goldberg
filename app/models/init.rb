class Init
  def run
    if Environment.argv.size > 0 && ['add', 'remove', 'list', 'start', 'start_poller'].include?(Environment.argv[0])
      send(Environment.argv[0])
    else
      Rails.logger.info "You did not pass any command."
      Rails.logger.info "Valid commands are add, remove, list, start & start_poller."
    end
  end

  def add
    if Environment.argv.size >= 3
      Project.add(:url => Environment.argv[1], :name => Environment.argv[2], :command => Environment.argv[3])
      Rails.logger.info "#{Environment.argv[2]} successfully added."
    else
      Rails.logger.info "Usage 'bin/goldberg add <url> <name> [custom_command]'"
    end
  end

  def remove
    if Environment.argv.size == 2
      Project.find_by_name(Environment.argv[1]).destroy
      Rails.logger.info "#{Environment.argv[1]} successfully removed."
    else
      Rails.logger.info "Usage 'bin/goldberg remove <name>'"
    end
  end

  def list
    Project.all.map(&:name).each{|name| Rails.logger.info name}
  end

  def start
    port = 3000
    if Environment.argv.size == 2
      port = Environment.argv[1].to_i
    end
    Environment.exec "rackup -p #{port} #{File.join(File.dirname(__FILE__), '..', '..', 'config.ru')}"
  end

  def poll
    Project.all.each do |p|
      begin
        p.update do |project|
          build_successful = project.build
          Rails.logger.info "Build #{ build_successful  ? "passed" : "failed!" }"
        end
      rescue Exception => e
        Rails.logger.error "Build on project #{p.name} failed because of #{e}"
      end
    end
  end

  def start_poller
    while true
      poll
      Rails.logger.info "Sleeping for 20 seconds."
      Environment.sleep(20)
    end
  end
end
