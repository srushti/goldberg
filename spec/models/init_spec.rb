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
    one.stub!(:run_build).and_raise(Exception.new("An exception"))
    two.should_receive(:run_build)
    Project.stub!(:all).and_return([one, two])
    Rails.logger.should_receive(:error).with("Build on project #{one.name} failed because of An exception")
    Init.new.poll
  end
end

