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

    it "removes the specifies project" do
      Environment.stub!(:argv).and_return(['remove', 'name'])
      project = mock(Goldberg::Project)
      Project.should_receive(:new).with('name').and_return(project)
      project.should_receive(:remove)
      Environment.should_receive(:puts).with('name successfully removed.')
      Init.new.run
    end

    it "lists all projects" do
      Environment.stub!(:argv).and_return(['list'])
      project = mock(Project, :name => 'name')
      Project.should_receive(:all).and_return([project])
      Environment.should_receive(:puts).with('name')
      Init.new.run
    end

    {(['start']) => 3000, (['start', '9292']) => 9292}.each_pair do |args, port|
      it "starts the app on port #{port} with arguments #{args}" do
        Environment.stub!(:argv).and_return(args)
        app_root = File.join(File.dirname(__FILE__)).split('/spec/goldberg')[0]
        Environment.should_receive(:exec).with("rackup -p #{port} #{File.join(app_root, 'lib', 'goldberg', '..', '..', 'config.ru')}")
        Init.new.run
      end
    end
  end
end

