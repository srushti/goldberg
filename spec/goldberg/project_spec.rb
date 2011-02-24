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
      project = Project.new('name')
      Environment.should_receive(:system_call_output).with('cd some_path/name/code ; git pull').and_return('some changes')
      project.should_receive(:write_build_version)
      project.update{|p| yielded_project = p}
      yielded_project.should == project
    end

    it "yields if there is a build to be forced even if there are no updates" do
      yielded_project = nil
      project = Project.new('name')
      ['build_status_path', 'build_log_path', 'force_build_path'].each do |method_name|
        File.should_receive(:exist?).with(project.send(method_name)).and_return(true)
      end
      Environment.should_receive(:system_call_output).with('cd some_path/name/code ; git pull').and_return('Already up-to-date.')
      project.should_receive(:write_build_version)
      project.update{|p| yielded_project = p}
      yielded_project.should == project
    end

    it "builds the default target" do
      Environment.should_receive(:system).with('cd some_path/name/code ; rake default 2>&1').and_yield('some log data', true)
      Environment.stub!(:write_file).with('some_path/name/build_log', 'some log data')
      Environment.stub!(:write_file).with('some_path/name/build_status', true)
      project = Project.new('name')
      project.should_receive(:latest_build_number).and_return(1)
      project.should_receive(:write_change_list)
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
      project.should_receive(:update)
      project.force_build
    end

    it "should get latest code when the build is forced" do
      project = Project.new('name')
      Environment.should_receive(:write_file).with(project.force_build_path, '')
      Environment.should_receive(:system_call_output).with('cd some_path/name/code ; git pull').and_return('some changes')
      project.should_receive(:build)
      project.should_receive(:write_build_version)
      project.force_build
    end

    it "should return the latest build time" do
      project = Project.new("name")
      File.should_receive(:ctime).with('some_path/name/build_status')
      project.last_built_at
    end

    it "should write the list of changes to change list file" do
      project = Project.new("name")
      latest_build = Build.new('latest_build_path')
      project.should_receive(:latest_build).and_return(latest_build)
      latest_build.should_receive(:version).and_return('HEAD~1')
      project.should_receive(:build_version).and_return('HEAD')
      Environment.should_receive(:system_call_output).with('cd some_path/name/code ; git diff --name-status HEAD~1 HEAD').and_return('change list')
      Environment.should_receive(:write_file).with('some_path/name/change_list', 'change list')
      project.write_change_list
    end

    it "should save the current build version" do
      project = Project.new('name')
      Environment.should_receive(:system_call_output).with('cd some_path/name/code ; git show-ref HEAD --hash').and_return('version')
      Environment.should_receive(:write_file).with('some_path/name/build_version', 'version')
      project.write_build_version
    end

    it "should return the current build version" do
      project = Project.new('name')
      Environment.should_receive(:read_file).with('some_path/name/build_version').and_return('version')
      project.build_version
    end
  end
end
