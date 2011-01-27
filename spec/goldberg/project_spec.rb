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

    it "updates but doesn't yield if there are no updates" do
      Environment.should_receive(:system_call_output).with('cd some_path/name ; git pull').and_return('Already up-to-date.')
      Project.new('name'){|p| true.should_not be}.update
    end

    it "updates and yields if there are updates" do
      yielded_project = nil
      Environment.should_receive(:system_call_output).with('cd some_path/name ; git pull').and_return('some changes')
      project = Project.new('name').update{|p| yielded_project = p}
      project.should == yielded_project
    end

    it "builds the default target" do
      Environment.should_receive(:system).with('cd some_path/name ; rake default').and_return(true)
      Environment.stub!(:write_file).with('some_path/name.status', true)
      Project.new('name').build
    end

    it "removes projects" do
      FileUtils.should_receive(:rm_rf).with('some_path/project_to_be_removed')
      Project.new('project_to_be_removed').remove
    end

    it "reports the status of the project" do
      File.should_receive(:exist?).with('some_path/name.status').and_return(true)
      Environment.should_receive(:read_file).with('some_path/name.status').and_return('build status')
      Project.new('name').status.should == 'build status'
    end
  end
end
