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

    it "writes the custom command if it is recieved when adding" do
      FileUtils.stub!(:mkdir_p).with('some_path/some_project')
      Environment.stub!(:system).and_return(true)
      Environment.should_receive(:write_file).with('some_path/some_project/custom_command', 'cmake')
      project = Project.add({:url => "git://some.url.git", :name => 'some_project', :command => 'cmake'})
    end

    it "should be able to retrieve the custom command" do
      File.should_receive(:exist?).with('some_path/name/custom_command').and_return(true)
      Environment.should_receive(:read_file).with('some_path/name/custom_command').and_return('cmake')
      project = Project.new('name')
      project.command.should == 'cmake'
    end

    it "should default the custom command to rake" do
      File.should_receive(:exist?).with('some_path/name/custom_command').and_return(false)
      project = Project.new('name')
      project.command.should == 'rake'
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
      project.update{|p| yielded_project = p}
      yielded_project.should == project
    end

    it "builds the default target" do
      Environment.should_receive(:system).with("source $HOME/.rvm/scripts/rvm && cd some_path/name/code && BUNDLE_GEMFILE='' rake default 2>&1").and_yield('some log data', true)
      Environment.stub!(:write_file).with('some_path/name/build_log', 'some log data')
      Environment.stub!(:write_file).with('some_path/name/build_status', true)
      project = Project.new('name')
      project.should_receive(:latest_build_number).and_return(1)
      project.should_receive(:write_change_list)
      project.should_receive(:write_build_version)
      project.should_receive(:command).and_return('rake')
      FileUtils.should_receive(:mkdir_p).with("some_path/name/builds/2", :verbose => true)
      FileUtils.should_receive(:cp).with(["some_path/name/build_status", "some_path/name/build_log", "some_path/name/build_version", "some_path/name/change_list"], "some_path/name/builds/2", :verbose => true)
      Environment.should_receive(:write_file).with(project.build_number_path, 2.to_s)
      project.build
    end

    it "removes projects" do
      FileUtils.should_receive(:rm_rf).with('some_path/project_to_be_removed/')
      Project.new('project_to_be_removed').remove
    end

    it "writes the build force file" do
      project = Project.new('name')
      Environment.should_receive(:write_file).with(project.force_build_path, '')
      Environment.stub!(:system_call_output).and_return('some changes')
      project.force_build
    end

    it "should get latest code when the build is forced" do
      project = Project.new('name')
      Environment.stub!(:write_file).with(project.force_build_path, '')
      Environment.should_receive(:system_call_output).with('cd some_path/name/code ; git pull').and_return('some changes')
      project.force_build
    end

    context "store change list for the build" do
      it "should write the list of changes to change list file" do
        project = Project.new("name")
        latest_build = Build.new('latest_build_path')
        project.stub!(:latest_build).and_return(latest_build)
        latest_build.stub!(:version).and_return('HEAD~1')
        project.should_receive(:build_version).and_return('HEAD')
        Environment.should_receive(:system_call_output).with('cd some_path/name/code ; git diff --name-status HEAD~1 HEAD').and_return('change list')
        Environment.should_receive(:write_file).with('some_path/name/change_list', 'change list')
        project.write_change_list
      end
      
      it "should not write change list in case of the first build" do
        project = Project.new("name")
        Build.should_receive(:all).and_return([])
        Environment.should_not_receive(:write_file)
        project.write_change_list
      end
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

    it "should be able to return the latest build" do
      project = Project.new('name')
      project.should_receive(:builds).and_return([mock('last_build', :number => '42'), mock('first_build', :number => '1')])
      project.latest_build.number.should == "42"
    end
  end
end
