require "spec_helper"

module Goldberg
  describe Project do
    before(:each) do
      Logger.stub!(:new).and_return(stub(Logger, :info => ''))
      Paths.stub!(:projects).and_return('some_path')
    end

    it "checks out a new git project" do
      FileUtils.should_receive(:mkdir_p).with('some_path/some_project')
      Environment.should_receive(:system).with('git clone git://some.url.git some_path/some_project/code').and_return(true)
      project = Project.add({:url => "git://some.url.git", :name => 'some_project'})
      project.name.should == 'some_project'
    end

    it "updates but doesn't yield if there are no updates" do
      project = Project.new('name')
      project.should_receive(:build_anyway?).and_return(false)
      Environment.should_receive(:system_call_output).with('cd some_path/name/code ; git pull').and_return('Already up-to-date.')
      project.update{|p| true.should_not be}
    end

    it "updates and yields if there are updates" do
      yielded_project = nil
      Environment.should_receive(:system_call_output).with('cd some_path/name/code ; git pull').and_return('some changes')
      project = Project.new('name').update{|p| yielded_project = p}
      yielded_project.should == project
    end

    it "yields if there are is build to be forced even if there are no updates" do
      yielded_project = nil
      project = Project.new('name')
      ['build_status_path', 'build_log_path', 'force_build_path'].each do |method_name|
        File.should_receive(:exist?).with(project.send(method_name)).and_return(true)
      end
      Environment.should_receive(:system_call_output).with('cd some_path/name/code ; git pull').and_return('Already up-to-date.')
      project.update{|p| yielded_project = p}
      yielded_project.should == project
    end

    it "builds the default target and copies the build to its own folder" do
      Environment.should_receive(:system).with('cd some_path/name/code ; rake default 2>&1').and_yield('some log data', true)
      Environment.stub!(:write_file).with('some_path/name/build_log', 'some log data')
      Environment.stub!(:write_file).with('some_path/name/build_status', true)
      project = Project.new('name')
      project.should_receive(:latest_build_number).and_return(1)
      FileUtils.should_receive(:mkdir_p).with("some_path/name/builds/2", :verbose => true)
      FileUtils.should_receive(:cp)
      Environment.should_receive(:write_file).with(project.build_number_path, 2.to_s)
      project.build
    end

    it "removes projects" do
      FileUtils.should_receive(:rm_rf).with('some_path/project_to_be_removed/')
      Project.new('project_to_be_removed').remove
    end

    it "reports the status of the project" do
      File.should_receive(:exist?).with('some_path/name/build_status').and_return(true)
      Environment.should_receive(:read_file).with('some_path/name/build_status').and_return('true')
      Project.new('name').status.should == true
    end

    it "writes the build force file" do
      project = Project.new('name')
      Environment.should_receive(:write_file).with(project.force_build_path, '')
      project.force_build
    end
  end
end
