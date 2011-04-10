class Init
  def bootstrap
    if File.exist?(File.join(Env['HOME'], '.rvm', 'scripts', 'rvm'))
      Rails.logger.info "It looks like you have RVM installed. We will now add the following settings to your global .rvmrc located at #{Env['HOME']}."
      goldberg_rvmrc_contents = "rvm_install_on_use_flag=1\nrvm_project_rvmrc=1\nrvm_gemset_create_on_use_flag=1"
      Rails.logger.info "#{goldberg_rvmrc_contents}\n(Y/n)"
      if ['yes', 'y'].include?(STDIN.gets.chomp.downcase)
        File.open(File.join(Env['HOME'], '.rvmrc'), 'a') { |f| f.write(goldberg_rvmrc_contents) }
      else
        Rails.logger.info "Aborting"
      end
    else
      Rails.logger.info "RVM doesn't seem to be installed! You can use Goldberg but all projects will be run on the default ruby: #{RUBY_VERSION}. If you wish to run on different rubies install rvm and run this 'bin/goldberg bootstrap' again."
    end
  end

  def add(url, name, command = nil)
    Project.add(:url => url, :name => name, :command => command)
    Rails.logger.info "#{name} successfully added."
  end

  def remove(name)
      Project.find_by_name(name).destroy
      Rails.logger.info "#{name} successfully removed."
  end

  def list
    Project.all.map(&:name).each { |name| Rails.logger.info name }
  end

  def start(port = 3000)
    Environment.exec "rackup -p #{port} #{File.join(File.dirname(__FILE__), '..', '..', 'config.ru')}"
  end

  def poll
    Project.all.each do |p|
      begin
        p.run_build
      rescue Exception => e
        Rails.logger.error "Build on project #{p.name} failed because of #{e}"
      end
    end
  end

  def start_poller
    while true
      poll
      Rails.logger.info "Sleeping for #{BuildConfig.frequency} seconds."
      Environment.sleep(BuildConfig.frequency)
    end
  end
end
