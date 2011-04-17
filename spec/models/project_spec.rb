require "spec_helper"

module Goldberg
  describe Project do
    before(:each) do
      Paths.stub!(:projects).and_return('some_path')
    end

    describe "attribute validation" do
      [:name, :url, :branch].each do |mandatory_field|
        it "should be invalid without a #{mandatory_field}" do
          project = Factory.build(:project, mandatory_field => nil)
          project.should have_at_least(1).error_on(mandatory_field)
          project.errors.full_messages.should include("#{mandatory_field.to_s.humanize} can't be blank")
        end
      end
    end

    describe "lifecycle" do
      context "adding a project" do
        it "creates a new projects and checks out the code for it" do
          Environment.should_receive(:system).with('git clone --depth 1 git://some.url.git some_path/some_project/code --branch master').and_return(true)
          lambda { Project.add({:url => "git://some.url.git", :name => 'some_project', :branch => 'master'}) }.should change(Project, :count).by(1)
        end
      end

      context "removing a project" do
        let(:project) { Factory(:project, :name => 'project_to_be_removed') }

        it "removes it from the DB" do
          project.destroy
          Project.find_by_name('project_to_be_removed').should be_nil
        end

        it "removes the checked out code and build info from filesystem" do
          FileUtils.should_receive(:rm_rf).with(project.path)
          project.destroy
        end

        it "removes all the builds from DB" do
          build = Factory(:build, :project => project)
          project.destroy
          Build.find_by_id(build.id).should be_nil
        end
      end
    end

    context "checkout" do
      it "checks out the code for the project" do
        project = Project.new(:url => "git://some.url.git", :name => 'some_project', :branch => 'master')
        Environment.should_receive(:system).with('git clone --depth 1 git://some.url.git some_path/some_project/code --branch master').and_return(true)
        project.checkout
      end
    end

    context "delegation to latest build" do
      [:number, :status, :log, :timestamp].each do |field|
        it "delegates latest_build_#{field} to the latest build" do
          project = Project.new
          latest_build = mock(Build)
          latest_build.should_receive(field)
          project.should_receive(:latest_build).and_return(latest_build)
          # testing delegation call through mocks
          project.send("latest_build_#{field}")
        end
      end
    end

    context "command" do
      it "does not prefix bundler related command if Gemfile is missing" do
        project = Factory(:project)
        File.should_receive(:exists?).with(File.join(project.code_path, 'Gemfile')).and_return(false)
        File.should_receive(:exists?).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return(false)
        project.command.starts_with?("(bundle check || bundle install)").should be_false
      end

      it "prefixes bundler related command if Gemfile is present" do
        project = Factory(:project)
        File.should_receive(:exists?).with(File.join(project.code_path, 'Gemfile')).and_return(true)
        File.should_receive(:exists?).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return(false)
        project.command.starts_with?("(bundle check || bundle install)").should be_true
      end

      it "is able to retrieve the custom command" do
        project = Factory(:project, :custom_command => 'cmake')
        project.command.should == 'cmake'
      end

      it "defaults the custom command to rake" do
        project = Factory(:project, :custom_command => nil)
        project.command.should == 'rake default'
      end
    end

    context "forcing a build" do
      it "sets the build requested flag to true" do
        project = Factory(:project, :name => 'name')
        project.force_build
        project.build_requested.should be_true
      end
    end

    context "when to build" do
      it "builds if there are no existing builds" do
        project = Project.new
        project.build_required?.should be_true
      end

      it "builds even if there are existing builds if it is requested" do
        project = Project.new
        project.builds << Build.new
        project.build_requested = true
        project.build_required?.should be_true
      end
    end

    context "run build" do
      let(:project) { Factory(:project, :name => "goldberg") }

      # all tests in this context are testing mock calls Grrrhhhhh

      it "preprocesses the codebase before calling build" do
        build = Build.new
        project.builds.should_receive(:create!).with(:number => 1, :previous_build_revision => "").and_return(build)
        build.should respond_to(:run)
        build.should_receive(:run)

        project.should respond_to(:prepare_for_build)
        project.should_receive(:prepare_for_build)
        project.repository.should_receive(:update).and_return(true)

        project.run_build
      end

      context "with build requested" do
        it "runs the build even if there are no updates" do
          build = Build.new
          project.build_requested = true
          project.repository.should_receive(:update).and_return(false)
          project.builds.should_receive(:create!).with(:number => 1, :previous_build_revision => "").and_return(build)
          build.should respond_to(:run)
          build.should_receive(:run)
          project.run_build
        end
      end

      context "without changes or requested build" do
        before :each do
          project.should respond_to(:build_required?)
          project.should_receive(:build_required?).and_return(false)
          project.repository.should_receive(:update).and_return(false)
        end

        it "does not run the build if there are no updates from repository or build is not required" do
          lambda { project.run_build }.should_not change(project.builds, :size)
        end

        it "schedules the next build based on the project's configuration" do
          project.next_build_at.should be_nil
          current_time = Time.now
          Time.stub!(:now).and_return(current_time)

          project.run_build

          Time.parse(project.reload.next_build_at.to_s).should == Time.parse((current_time + project.config.frequency.seconds).to_s)
        end
      end

      context "with changes" do
        let(:build) { Build.new }
        before(:each) do
          project.repository.should respond_to(:update)
          project.repository.should_receive(:update).and_return(true)
          build.should respond_to(:run)
          build.should_receive(:run)
        end

        it "creates a new build for a project with build number set to 1 in case of first build  and run it" do
          project.builds.should_receive(:create!).with(:number => 1, :previous_build_revision => "").and_return(build)
          project.run_build
        end

        it "creates a new build for a project with build number one greater than last build and run it" do
          project.builds << Factory(:build, :number => 5, :revision => "old_sha", :project => project)
          project.builds.should_receive(:create!).with(:number => 6, :previous_build_revision => "old_sha").and_return(build)
          project.run_build
        end

        it "schedules the next build based on the project's configuration" do
          project.next_build_at.should be_nil
          current_time = Time.now
          Time.stub!(:now).and_return(current_time)

          project.builds.should_receive(:create!).and_return(build)
          project.run_build

          Time.parse(project.reload.next_build_at.to_s).should == Time.parse((current_time + project.config.frequency.seconds).to_s)
        end
      end
    end

    it "is able to return the latest build" do
      project = Factory(:project, :name => 'name')
      first_build = Factory(:build, :project => project)
      last_build = Factory(:build, :project => project)
      project.latest_build.should == last_build
    end

    describe "build preprocessing" do
      let(:project) { Factory(:project, :name => "goldberg") }

      it "removes Gemfile.lock if the file exists and is not being versioned and if it is newer than the Gemfile" do
        gemfilelock_path = File.expand_path('Gemfile.lock', project.code_path)
        gemfile_path = File.expand_path('Gemfile', project.code_path)
        File.should_receive(:exists?).with(gemfilelock_path).and_return(true)
        project.repository.should_receive(:versioned?).with('Gemfile.lock').and_return(false)
        File.should_receive(:delete).with(gemfilelock_path)
        File.should_receive(:mtime).with(gemfilelock_path).and_return(2.days.ago)
        File.should_receive(:mtime).with(gemfile_path).and_return(1.days.ago)
        project.prepare_for_build
      end

      it "does not remove Gemfile.lock if the file exists but it's being versioned" do
        File.should_receive(:exists?).with(File.expand_path('Gemfile.lock', project.code_path)).and_return(true)
        project.repository.should_receive(:versioned?).with('Gemfile.lock').and_return(true)
        File.should_not_receive(:delete).with(File.expand_path('Gemfile.lock', project.code_path))
        project.prepare_for_build
      end
    end

    describe "project configuration" do
      let(:project) { Factory(:project, :name => 'goldberg') }

      it "loads a new configuration object with default values if goldberg_config.rb is not found" do
        File.should_receive(:exists?).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return(false)
        File.should_not_receive(:read).with(File.expand_path('goldberg_config.rb', project.code_path))
        project.config.should_not be_nil
      end

      it "evals the goldberg_config.rb and returns the modified config as project config when file exists" do
        File.should_receive(:exists?).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return(true)
        File.should_receive(:read).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return("Project.configure{|c| c.frequency = 30 }")
        project.config.frequency.should == 30
      end
    end

    it "provides list of projects to be built" do
      new_project = Factory(:project)
      build_due_project = Factory(:project, :next_build_at => Time.now - 10.seconds)
      build_not_due_project = Factory(:project, :next_build_at => Time.now + 1.hour)
      undue_but_forced_project = Factory(:project, :next_build_at => Time.now + 1.hour, :build_requested => true)
      Project.projects_to_build.should include(new_project)
      Project.projects_to_build.should include(build_due_project)
      Project.projects_to_build.should include(undue_but_forced_project)
      Project.projects_to_build.should_not include(build_not_due_project)
    end
  end
end
