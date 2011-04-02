class Init
  def self.allowed_methods
    ['bootstrap', 'add', 'remove', 'list', 'start', 'start_poller']
  end

  def run
    if Environment.argv.size > 0 && Init::allowed_methods.include?(Environment.argv[0])
      send(Environment.argv[0])
    else
      Rails.logger.info "You did not pass any command."
      Rails.logger.info "Valid commands are #{Init::allowed_methods.join(', ')}."
    end
  end

  def bootstrap
    if File.exist?(File.join(Env['HOME'], '.rvm', 'scripts', 'rvm'))
      Rails.logger.info "It looks like you have RVM installed. We will now add the following settings to your global .rvmrc located at #{Env['HOME']}."
      goldberg_rvmrc_contents =  "rvm_install_on_use_flag=1\nrvm_project_rvmrc=1\nrvm_gemset_create_on_use_flag=1"
      Rails.logger.info "#{goldberg_rvmrc_contents}\n(Y/n)"
      if ['yes', 'y'].include?(STDIN.gets.chomp.downcase)
        File.open(File.join(Env['HOME'], '.rvmrc'), 'a') {|f| f.write(goldberg_rvmrc_contents)}
      else
        Rails.logger.info "Aborting"
      end
    else
      Rails.logger.info "RVM doesn't seem to be installed! You can use Goldberg but all projects will be run on the default ruby: #{RUBY_VERSION}. If you wish to run on different rubies install rvm and run this 'bin/goldberg bootstrap' again."
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
        p.run_build
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
