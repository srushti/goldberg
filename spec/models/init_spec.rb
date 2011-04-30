require "spec_helper"

describe Init do
  it "adds a new project" do
    Project.should_receive(:add).with(:url => 'url', :name => 'name', :command => nil, :branch => 'master')
    Rails.logger.should_receive(:info).with('name successfully added.')
    Init.new.add('url','name','master')
  end

  it "adds a new project with a custom command" do
    Project.should_receive(:add).with(:url => 'url', :name => 'name', :command => 'cmake', :branch => 'master')
    Rails.logger.should_receive(:info).with('name successfully added.')
    Init.new.add('url','name', 'master', 'cmake')
  end

  it "removes the specified project" do
    project = Factory(:project, :name => 'name')
    Rails.logger.should_receive(:info).with('name successfully removed.')
    Init.new.remove('name')
    Project.find_by_id(project.id).should_not be
  end

  it "fails gracefully if it can't find the project to remove" do
    Rails.logger.should_receive(:error).with("Project unknown does not exist.")
    Init.new.remove('unknown')
  end

  it "lists all projects" do
    project = Factory(:project, :name => 'a_project')
    Rails.logger.should_receive(:info).with(project.name)
    Init.new.list
  end

  it "starts the app on port 3000 if no port specified" do
    Environment.should_receive(:exec).with("rackup -p 3000 -D -P #{File.join(ENV["GOLDBERG_PATH"], "pids", "goldberg.pid")} #{File.join(Rails.root, 'app', 'models', '..', '..', 'config.ru')}")
    Init.new.start
  end

  it "starts the app on specified port if port specified" do
    Environment.should_receive(:exec).with("rackup -p 4356 -D -P #{File.join(ENV["GOLDBERG_PATH"], "pids", "goldberg.pid")} #{File.join(Rails.root, 'app', 'models', '..', '..', 'config.ru')}")
    Init.new.start(4356)
  end

  it "does not start the app if the pid file already exists" do
    Paths.stub!(:pid).and_return("pid_path")
    File.should_receive(:exist?).with("pid_path").and_return(true)
    Rails.logger.should_receive(:info).with("Goldberg already appears to be running. Please run 'bin/goldberg stop' or delete the existing pid file.")
    Init.new.start
  end

  it "stops the app and removes the pid file" do
    Paths.stub!(:pid).and_return("pid_path")
    File.should_receive(:exist?).with("pid_path").and_return(true)
    Environment.should_receive(:exec).with("kill `cat pid_path`")
    FileUtils.should_receive(:rm).with("pid_path")
    Init.new.stop
  end

  it "prints a warning if attempting to stop with no pid file" do
    Paths.stub!(:pid).and_return("pid_path")
    File.should_receive(:exist?).with("pid_path").and_return(false)
    Rails.logger.should_receive(:info).with("Goldberg does not appear to be running.")
    Init.new.stop
  end

  it "continues on with the next project even if one build fails" do
    one = Factory(:project, :name => 'one')
    two = Factory(:project, :name => 'two')
    exception = Exception.new("An exception")
    one.stub!(:run_build).and_raise(exception)
    two.should_receive(:run_build)
    Project.stub!(:projects_to_build).and_return([one, two])
    Rails.logger.should_receive(:error).with("Build on project #{one.name} failed because of An exception")
    Rails.logger.should_receive(:error)
    Init.new.poll
  end

  describe "bootstrap" do
    it "suggests the user install rvm if it isn't" do
      RVM.stub!(:installed?).and_return(false)
      Rails.logger.should_receive(:info).with("RVM doesn't seem to be installed!\nYou can use Goldberg but all projects will be run on the default ruby: #{RUBY_ENGINE} #{RUBY_VERSION}.\nIf you wish to run on different rubies install rvm and run this 'bin/goldberg bootstrap' again.")
      Init.new.bootstrap
    end

    context "rvm installed" do
      before(:each) do
        RVM.stub!(:installed?).and_return(true)
        Rails.logger.should_receive(:info).with("It looks like you have RVM installed. We will now add the following settings to your global .rvmrc located at #{Env['HOME']}.")
        Rails.logger.should_receive(:info).with("#{RVM.goldberg_rvmrc_contents}\n(Y/n)")
      end

      ["YeS\n", "Y\r"].each do |response|
        it "adds the required settings to .rvmrc if the user says #{response}" do
          Environment.stub!(:stdin).and_return(mock(:stdin, :gets => response))
          RVM.should_receive(:write_goldberg_rvmrc_contents)
          Init.new.bootstrap
        end
      end

      it "doesn't add the required settings to .rvmrc if the user says 'no'" do
        Environment.stub!(:stdin).and_return(mock(:stdin, :gets => 'no'))
        RVM.should_not_receive(:write_goldberg_rvmrc_contents)
        Rails.logger.should_receive(:info).with('Aborting')
        Init.new.bootstrap
      end
    end
  end
end

