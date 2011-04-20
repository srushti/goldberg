module RVM
  class << self
    def installed?
      File.exist?(File.join(Env['HOME'], '.rvm', 'scripts', 'rvm'))
    end

    def goldberg_rvmrc_contents
      "rvm_install_on_use_flag=1\nrvm_project_rvmrc=1\nrvm_gemset_create_on_use_flag=1"
    end

    def write_goldberg_rvmrc_contents
      File.open(File.join(Env['HOME'], '.rvmrc'), 'a') {|f| f.write(goldberg_rvmrc_contents)}
    end

    def use_script(ruby, gemset)
      installed? ? "#{source_script} $HOME/.rvm/scripts/rvm && rvm use #{ruby}@#{gemset}" : ''
    end

    def source_script
      "source $HOME/.rvm/scripts/rvm"
    end

    def prepare_ruby(ruby)
      return unless installed?
      Environment.system("#{use_script(ruby, 'global')} && (gem list | grep bundler) || gem install bundler")
    end
  end
end
