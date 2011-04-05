require "spec_helper"

describe GoldbergInit do
  it "adds a new project" do
    Environment.stub!(:argv).and_return(['add', 'url', 'name'])
    Project.should_receive(:add).with(:url => 'url', :name => 'name', :command => nil)
    Rails.logger.should_receive(:info).with('name successfully added.')
    GoldbergInit.new.run
  end

  it "adds a new project with a custom command" do
    Environment.stub!(:argv).and_return(['add', 'url', 'name', 'cmake'])
    Project.should_receive(:add).with(:url => 'url', :name => 'name', :command => 'cmake')
    Rails.logger.should_receive(:info).with('name successfully added.')
    GoldbergInit.new.run
  end

  it "removes the specified project" do
    Environment.stub!(:argv).and_return(['remove', 'name'])
    project = Factory(:project, :name => 'name')
    Rails.logger.should_receive(:info).with('name successfully removed.')
    GoldbergInit.new.run
    Project.find_by_id(project.id).should_not be
  end

  it "lists all projects" do
    project = Factory(:project, :name => 'a_project')
    Environment.stub!(:argv).and_return(['list'])
    Rails.logger.should_receive(:info).with(project.name)
    GoldbergInit.new.run
  end

  {(['start']) => 3000, (['start', '9292']) => 9292}.each_pair do |args, port|
    it "starts the app on port #{port} with arguments #{args}" do
      Environment.stub!(:argv).and_return(args)
      app_root = File.join(File.dirname(__FILE__)).split('/spec/goldberg')[0]
      Environment.should_receive(:exec).with("rackup -p #{port} #{File.join(Rails.root, 'app', 'models', '..', '..', 'config.ru')}")
      GoldbergInit.new.run
    end
  end

  it "continues on with the next project even if one build fails" do
    one = Factory(:project, :name => 'one')
    two = Factory(:project, :name => 'two')
    one.stub!(:run_build).and_raise(Exception.new("An exception"))
    two.should_receive(:run_build)
    Project.stub!(:all).and_return([one, two])
    Rails.logger.should_receive(:error).with("Build on project #{one.name} failed because of An exception")
    GoldbergInit.new.poll
  end
end

