require "spec_helper"

describe Init do
  it "adds a new project" do
    Project.should_receive(:add).with(:url => 'url', :name => 'name', :command => nil)
    Rails.logger.should_receive(:info).with('name successfully added.')
    Init.new.add('url','name')
  end

  it "adds a new project with a custom command" do
    Project.should_receive(:add).with(:url => 'url', :name => 'name', :command => 'cmake')
    Rails.logger.should_receive(:info).with('name successfully added.')
    Init.new.add('url','name','cmake')
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
    Environment.should_receive(:exec).with("rackup -p 3000 #{File.join(Rails.root, 'app', 'models', '..', '..', 'config.ru')}")
    Init.new.start
  end

  it "starts the app on specified port if port specified" do
    Environment.should_receive(:exec).with("rackup -p 4356 #{File.join(Rails.root, 'app', 'models', '..', '..', 'config.ru')}")
    Init.new.start(4356)
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

