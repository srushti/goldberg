require "spec_helper"

module Goldberg
  describe Init do
    it "adds a new project" do
      Environment.stub!(:argv).and_return(['add', 'url', 'name'])
      Project.should_receive(:add).with(:url => 'url', :name => 'name', :command => nil)
      Environment.should_receive(:puts).with('name successfully added.')
      Init.new.run
    end

    it "adds a new project with a custom command" do
      Environment.stub!(:argv).and_return(['add', 'url', 'name', 'cmake'])
      Project.should_receive(:add).with(:url => 'url', :name => 'name', :command => 'cmake')
      Environment.should_receive(:puts).with('name successfully added.')
      Init.new.run
    end

    it "removes the specified project" do
      Environment.stub!(:argv).and_return(['remove', 'name'])
      project = Factory(:project, :name => 'name')
      Environment.should_receive(:puts).with('name successfully removed.')
      Init.new.run
      Project.find_by_id(project.id).should_not be
    end

    it "lists all projects" do
      project = Factory(:project, :name => 'a_project')
      Environment.stub!(:argv).and_return(['list'])
      Environment.should_receive(:puts).with(project.name)
      Init.new.run
    end

    {(['start']) => 3000, (['start', '9292']) => 9292}.each_pair do |args, port|
      it "starts the app on port #{port} with arguments #{args}" do
        Environment.stub!(:argv).and_return(args)
        app_root = File.join(File.dirname(__FILE__)).split('/spec/goldberg')[0]
        Environment.should_receive(:exec).with("rackup -p #{port} #{File.join(Rails.root, 'app', 'models', '..', '..', 'config.ru')}")
        Init.new.run
      end
    end

    it "continues on with the next project even if one build fails" do
      one = Factory(:project, :name => 'one')
      two = Factory(:project, :name => 'two')
      one.stub!(:update).and_raise(Exception.new("An exception"))
      two.should_receive(:update)
      Project.stub!(:all).and_return([one, two])
      logger = mock('logger')
      logger.should_receive(:error).with("Build on project #{one.name} failed because of An exception")
      Logger.stub!(:new).and_return(logger)
      Init.new.poll
    end
  end
end

