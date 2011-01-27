require "spec_helper"

module Goldberg
  describe Project do
    before(:each) do
      Logger.stub!(:new).and_return(stub(Logger, :info => ''))
      Paths.stub!(:projects).and_return('some_path')
    end

    it "checks out a new git project" do
      Git.should_receive(:clone).with('git://some.url.git', 'some_project', :path => 'some_path')
      project = Project.add({:url => "git://some.url.git", :name => 'some_project'})
      project.name.should == 'some_project'
    end

    it "updates the project" do
      git = mock(Git)
      Git.should_receive(:open).with('some_path/name', anything).and_return(git)
      git.should_receive(:fetch).and_return('')
      Project.new('name').update
    end

    it "updates and lets you know if there were updates" do
      git = mock(Git)
      Git.stub!(:open).with('some_path/name', anything).and_return(git)
      git.stub!(:fetch).and_return('')
      Project.new('name').update.should == false
    end

    it "updates and lets you know when there were no changes" do
      git = mock(Git)
      Git.stub!(:open).with('some_path/name', anything).and_return(git)
      git.stub!(:fetch).and_return('some changes')
      git.should_receive(:merge)
      Project.new('name').update.should == true
    end

    it "builds the default target" do
      Environment.should_receive(:system).with('cd some_path/name ; rake default').and_return(true)
      Environment.stub!(:write_file).with('some_path/name.status', true)
      Project.new('name').build
    end

    it "removes projects" do
      FileUtils.should_receive(:rm_rf).with('some_path/project_to_be_removed')
      Project.remove('project_to_be_removed')
    end

    it "reports the status of the project" do
      File.should_receive(:exist?).with('some_path/name.status').and_return(true)
      Environment.should_receive(:read_file).with('some_path/name.status').and_return('build status')
      Project.new('name').status.should == 'build status'
    end
  end
end
