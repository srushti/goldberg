require "spec_helper"

module Goldberg
  describe Project do
    before(:each) do
      Logger.stub!(:new).and_return(stub(Logger, :info => ''))
      Paths.stub!(:projects).and_return('some_path')
    end

    it "checks out a new git project" do
      FileUtils.should_receive(:mkdir_p).with('some_path/some_project')
      Environment.should_receive(:system).with('git clone --depth 1 git://some.url.git some_path/some_project/code').and_return(true)
      project = Project.add({:url => "git://some.url.git", :name => 'some_project'})
      project.name.should == 'some_project'
    end

    it "should be able to retrieve the custom command" do
      project = Factory(:project, :custom_command => 'cmake')
      project.command.should == 'cmake'
    end

    it "should default the custom command to rake" do
      project = Factory(:project, :custom_command => nil)
      project.command.should == 'rake'
    end

    it "updates but doesn't yield if there are no updates" do
      project = Factory(:project, :name => 'name')
      project.should_receive(:build_anyway?).and_return(false)
      project.repository.should_receive(:update).and_return(false)
      project.update{|p| true.should_not be}
    end

    it "updates and yields if there are updates" do
      yielded_project = nil
      project = Factory(:project, :name => 'name')
      project.repository.should_receive(:update).and_return(false)
      project.update{|p| yielded_project = p}
      yielded_project.should == project
    end

    it "yields if there is a build to be forced even if there are no updates" do
      yielded_project = nil
      project = Factory(:project, :name => 'name')
      ['build_status_path', 'build_log_path', 'force_build_path'].each do |method_name|
        File.should_receive(:exist?).with(project.send(method_name)).and_return(true)
      end
      project.repository.should_receive(:update).and_return(false)
      project.update{|p| yielded_project = p}
      yielded_project.should == project
    end

    it "builds the default target" do
      pending
      Environment.should_receive(:system).with("source $HOME/.rvm/scripts/rvm && cd some_path/name/code && BUNDLE_GEMFILE='' rake default 2>&1").and_yield('some log data', true)
      Environment.stub!(:write_file).with('some_path/name/build_log', 'some log data')
      project = Factory(:project, :name => 'name', :builds => [Factory(:build, :number => 1)])
      FileUtils.should_receive(:mkdir_p).with("some_path/name/builds/2", :verbose => true)
      FileUtils.should_receive(:cp).with( "some_path/name/build_log", "some_path/name/builds/2", :verbose => true)
      project.build
    end

    it "removes projects" do
      FileUtils.should_receive(:rm_rf).with('some_path/project_to_be_removed/')
      project = Factory(:project, :name => 'project_to_be_removed')
      project.destroy
    end

    it "writes the build force file" do
      project = Factory(:project, :name => 'name')
      Environment.should_receive(:write_file).with(project.force_build_path, '')
      Environment.stub!(:system_call_output).and_return('some changes')
      project.force_build
    end

    it "should get latest code when the build is forced" do
      project = Factory(:project, :name => 'name')
      Environment.stub!(:write_file).with(project.force_build_path, '')
      project.repository.should_receive(:update).and_return(true)
      project.force_build
    end

    context "run build" do
      let(:project) { Factory(:project, :name => "goldberg") }

      it "should create a new build for a project with build number set to 1 in case of first build  and run it" do
        Environment.should_receive(:system).and_return(true)
        project.repository.should_receive(:change_list).and_return("")
        File.should_receive(:open)
        project.run_build.should == true
        project.builds.should have(1).thing
        project.builds.last.number.should == 1
      end
      
      it "should create a new build for a project with build number one greater than last build and run it" do
        Environment.should_receive(:system).and_return(true)
        project.repository.should_receive(:revision).and_return("new_sha")
        project.repository.should_receive(:change_list).with("random_sha", "new_sha").and_return("")
        File.should_receive(:open)
        project.builds.create(:number => 5, :revision => "random_sha", :project => project)
        project.run_build.should == true
        project.builds.last.number.should == 6
      end
    end
    
    it "should be able to return the latest build" do
      project = Factory(:project, :name => 'name')
      project.should_receive(:builds).and_return([mock('last_build', :number => '42'), mock('first_build', :number => '1')])
      project.latest_build.number.should == "42"
    end
  end
end
