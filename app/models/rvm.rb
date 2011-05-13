module RVM
  class << self
    def rvm_script_path
      File.join(Env['HOME'], '.rvm', 'scripts', 'rvm')
    end

    def installed?
      File.exist?(rvm_script_path)
    end

    def ci_rvmrc_contents
      "rvm_install_on_use_flag=1\n" +  #so that new rubies are added as and when they are needed
      "rvm_project_rvmrc=0\n" +       #we need to ignore the checked in .rvmrc, since they give a warning which we can't respond to in an automated way
      "rvm_gemset_create_on_use_flag=1\n"  #similar to the first setting, but it helps us create gemsets easily
    end

    def write_ci_rvmrc_contents
      Environment.write_file(File.join(Env['HOME'], '.rvmrc'), ci_rvmrc_contents)
    end

    def use_script(ruby, gemset)
      installed? ? "#{source_script} && rvm use #{ruby}@#{gemset}" : nil
    end

    def source_script
      "source #{rvm_script_path}"
    end

    def prepare_ruby(ruby)
      return unless installed?
      Environment.system("#{use_script(ruby, 'global')} && (gem list | grep bundler) || gem install bundler")
    end

    def trust_rvmrc(project_root)
      return unless installed?
      Environment.system("rvm rvmrc trust #{project_root}")
    end
  end
end
