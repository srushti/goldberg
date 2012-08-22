require "spec_helper"

describe Project do
  before(:each) do
    Paths.stub(:projects).and_return('some_path')
  end

  describe "attribute validation" do
    [:name, :url, :branch].each do |mandatory_field|
      it "should be invalid without a #{mandatory_field}" do
        project = FactoryGirl.build(:project, mandatory_field => nil)
        project.should have_at_least(1).error_on(mandatory_field)
        project.errors.full_messages.should include("#{mandatory_field.to_s.humanize} can't be blank")
      end
    end
  end

  describe "lifecycle" do
    context "adding a project" do
      it "creates a new projects and checks out the code for it" do
        expect_command('git clone --depth 1 git://some.url.git some_path/some_project/code --branch master', :execute => true)
        lambda { Project.add({:url => "git://some.url.git", :name => 'some_project', :branch => 'master', :scm => 'git'}) }.should change(Project, :count).by(1)
      end

      it "doesn't do anything if a project already exists with the same name" do
        FactoryGirl.create(:project, :name => 'foo')
        lambda { Project.add(:name => 'foo').should be_nil }.should_not change(Project, :count)
      end
    end

    context "removing a project" do
      let(:project) { FactoryGirl.create(:project, :name => 'project_to_be_removed') }

      it "removes it from the DB" do
        project.destroy
        Project.find_by_name('project_to_be_removed').should be_nil
      end

      it "removes the checked out code and build info from filesystem" do
        FileUtils.should_receive(:rm_rf).with(project.path)
        project.destroy
      end

      it "removes all the builds from DB" do
        build = FactoryGirl.create(:build, :project => project)
        project.destroy
        Build.find_by_id(build.id).should be_nil
      end
    end
  end

  describe "checkout" do
    it "checks out the code for the project" do
      project = Project.new(:url => "git://some.url.git", :name => 'some_project', :branch => 'master', :scm => 'git')
      expect_command('git clone --depth 1 git://some.url.git some_path/some_project/code --branch master', :execute => true)
      project.checkout
    end

    it "doesn't create the project if the checkout fails" do
      lambda {
        expect_command('git clone --depth 1 git://some.url.git some_path/some_project/code --branch master', :execute => false)
        Project.add(:url => 'git://some.url.git', :name => 'some_project', :branch => 'master', :scm => 'git')
      }.should_not change(Project, :count)
    end
  end

  describe "delegation to latest build" do
    [:number, :status, :build_log, :timestamp].each do |field|
      it "delegates latest_build_#{field} to the latest build" do
        project = Project.new
        latest_build = mock(Build)
        latest_build.should_receive(field).and_return('a value')
        project.should_receive(:latest_build).and_return(latest_build)
        # testing delegation call through mocks
        project.send("latest_build_#{field}").should == 'a value'
      end
    end
  end

  describe "last complete build" do
    [:timestamp].each do |field|
      it "delegates last_complete_build_#{field} to the last complete build" do
        project = FactoryGirl.create(:project)
        FactoryGirl.create(:build, :project => project, :number => 4, :status => 'passed').update_attributes(:created_at => 2.days.ago)
        FactoryGirl.create(:build, :project => project, :number => 5, :status => 'building').update_attributes(:created_at => 1.day.ago)
        FactoryGirl.create(:build, :project => project, :number => 5, :status => 'cancelled').update_attributes(:created_at => Date.today)
        project.last_complete_build_status.to_s.should == 'passed'
      end
    end
  end

  describe "command" do
    let(:project) { FactoryGirl.create(:project) }

    it "defaults the custom command to rake" do
      project.build_command.should eq('rake default')
    end

    it "is able to retrieve the custom command" do
      File.stub(:exists?).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return(true)
      File.stub(:exists?).with(File.expand_path('goldberg_config.rb', project.path)).and_return(false)
      Environment.stub(:read_file).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return("Project.configure { |config| config.command = 'cmake' }")
      project.build_command.should eq('cmake')
    end

    it "does 'bundle exec' if asked to" do
      File.stub(:exists?).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return(true)
      File.stub(:exists?).with(File.expand_path('goldberg_config.rb', project.path)).and_return(false)
      Environment.stub(:read_file).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return("Project.configure { |config| config.use_bundle_exec = true }")
      project.build_command.should == 'bundle exec rake default'
    end
  end

  describe "forcing a build" do
    it "sets the build requested flag to true" do
      project = FactoryGirl.create(:project, :name => 'name')
      project.force_build
      project.build_requested.should be_true
    end
  end

  describe "when to build" do
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

  describe "run build" do
    let(:project) { FactoryGirl.create(:project, :name => "goldberg") }

    before(:each) do
      File.stub(:exist?).with(File.expand_path('Gemfile', project.code_path)).and_return(false)
    end
    # all tests in this context are testing mock calls Grrrhhhhh

    it "preprocesses the codebase before calling build" do
      build = Build.new
      project.should_receive(:new_build).with(:number => 1, :previous_build_revision => "", :ruby => anything, :environment_string => "").and_return(build)
      build.should respond_to(:run)
      build.should_receive(:run)

      project.repository.should_receive(:update).and_return(true)
      project.run_build
    end

    context "with build requested" do
      it "runs the build even if there are no updates" do
        build = Build.new
        project.build_requested = true
        project.repository.should_receive(:update).and_return(false)
        project.should_receive(:new_build).and_return(build)
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
        Time.stub(:now).and_return(current_time)

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
        project.should_receive(:new_build).with(hash_including(:number => 1)).and_return(build)
        project.run_build
      end

      it "creates a new build for a project with build number one greater than last build and run it" do
        project.builds << FactoryGirl.create(:build, :number => 5, :revision => "old_sha", :project => project)
        project.should_receive(:new_build).with(hash_including(:number => 6, :previous_build_revision => "old_sha")).and_return(build)
        project.run_build
      end

      it "schedules the next build based on the project's configuration" do
        project.next_build_at.should be_nil
        current_time = Time.now
        Time.stub(:now).and_return(current_time)

        project.should_receive(:new_build).and_return(build)
        project.run_build

        Time.parse(project.reload.next_build_at.to_s).should == Time.parse((current_time + project.config.frequency.seconds).to_s)
      end

      it "should read the environment variables from the config" do
        config = Project::Configuration.new.tap{ |c| c.stub(:environment_string).and_return("FOO=bar") }
        project.stub(:config).and_return(config)
        project.should_receive(:new_build).with(hash_including(:environment_string => "FOO=bar")).and_return(build)
        project.run_build
      end

      it "should execute the post_build hooks from the config" do
        callback_tester = mock
        mail_notification = mock

        BuildMailNotification.stub(:new).and_return(mail_notification)
        configuration = Project.configure do |config|
          config.on_build_completion do |build, notification, prev_build_status|
            callback_tester.test_call(build, notification, prev_build_status)
          end
        end

        latest_build = Build.new :number => 8, :status => 'prev_status'
        project.builds << latest_build

        callback_tester.should_receive(:test_call).with(build, mail_notification,'prev_status')

        project.stub(:config).and_return(configuration)
        project.stub(:new_build).and_return(build)

        project.run_build
      end
    end
  end

  it "is able to return the latest build" do
    project = FactoryGirl.create(:project, :name => 'name')
    first_build = FactoryGirl.create(:build, :project => project)
    last_build = FactoryGirl.create(:build, :project => project)
    project.latest_build.should == last_build
  end

  it "cleans up older 'building' builds" do
    project = FactoryGirl.create(:project)
    passed_build = FactoryGirl.create(:build, :project => project, :status => 'passed')
    failed_build = FactoryGirl.create(:build, :project => project, :status => 'failed')
    interrupted_build = FactoryGirl.create(:build, :project => project, :status => 'building')
    project.clean_up_older_builds
    interrupted_build.reload.status.should == 'cancelled'
    passed_build.reload.status.should == 'passed'
    failed_build.reload.status.should == 'failed'
  end

  describe "culprit_revision_range" do
    it "returns build which originally failed " do
      project = FactoryGirl.create(:project)
      passed_build = FactoryGirl.create(:build, :project => project, :status => 'passed',:revision => 'passed1')
      culprit_build = FactoryGirl.create(:build, :project => project, :status => 'failed',:revision => 'failed1')
      innocent_build = FactoryGirl.create(:build, :project => project, :status => 'failed',:revision => 'failed2')
      project.culprit_revision_range.should == [innocent_build, culprit_build]
    end

    it "returns all failed build if there are no passing builds" do
      project = FactoryGirl.create(:project)
      culprit_build = FactoryGirl.create(:build, :project => project, :status => 'failed')
      innocent_build2 = FactoryGirl.create(:build, :project => project, :status => 'failed')
      innocent_build1 = FactoryGirl.create(:build, :project => project, :status => 'failed')
      project.culprit_revision_range.should == [innocent_build1, innocent_build2, culprit_build]
    end

    it "returns nil if the latest build passed" do
      project = FactoryGirl.create(:project)
      failed_build = FactoryGirl.create(:build, :project => project, :status => 'failed')
      passed_build = FactoryGirl.create(:build, :project => project, :status => 'passed')
      project.culprit_revision_range.should be_empty
    end
  end

  describe "culprits_for_failure" do
    it "returns authors of the culprit build" do
      project = FactoryGirl.create(:project)
      passed_build = FactoryGirl.create(:build, :project => project, :status => 'passed', :revision => 'passed_revision')
      failed_build = FactoryGirl.create(:build, :project => project, :status => 'failed', :revision => 'failed_revision')

      project.repository.should_receive(:authors).with(['failed_revision'])
      project.culprits_for_failure
    end

    it "returns empty string if there is no culprit build" do
      repository = mock(Repository)
      repository.should_not_receive(:authors)
      Repository.stub(:new).and_return(repository)
      project = FactoryGirl.create(:project)
      passed_build = FactoryGirl.create(:build, :project => project, :status => 'passed')
      project.culprits_for_failure.should  == ''
    end
  end

  describe "build preprocessing" do
    let(:project) { FactoryGirl.create(:project, :name => "goldberg") }

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
    let(:project) { FactoryGirl.create(:project, :name => 'goldberg') }

    it "loads a new configuration object with default values if goldberg_config.rb is not found" do
      File.stub(:exists?).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return(false)
      File.stub(:exists?).with(File.expand_path('goldberg_config.rb', project.path)).and_return(false)
      Environment.should_not_receive(:read_file).with(File.expand_path('goldberg_config.rb', project.code_path))
      Environment.should_not_receive(:read_file).with(File.expand_path('goldberg_config.rb', project.path))
      project.config.should_not be_nil
    end

    it "evals the goldberg_config.rb and returns the modified config as project config when file exists" do
      File.stub(:exists?).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return(true)
      File.stub(:exists?).with(File.expand_path('goldberg_config.rb', project.path)).and_return(false)
      Environment.stub(:read_file).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return("Project.configure{|c| c.frequency = 30 }")
      project.config.frequency.should == 30
    end

    it "loads the server-side config which overrides the checked in version" do
      File.stub(:exists?).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return(true)
      File.stub(:exists?).with(File.expand_path('goldberg_config.rb', project.path)).and_return(true)
      Environment.stub(:read_file).with(File.expand_path('goldberg_config.rb', project.code_path)).and_return("Project.configure{|c| c.frequency = 30; c.ruby = 'rbx' }")
      Environment.stub(:read_file).with(File.expand_path('goldberg_config.rb', project.path)).and_return("Project.configure{|c| c.frequency = 45; c.nice = '+1' }")
      project.config.frequency.should == 45
      project.config.ruby.should == 'rbx'
      project.config.nice.should == '+1'
    end
  end

  it "provides list of projects to be built" do
    new_project = FactoryGirl.create(:project)
    build_due_project = FactoryGirl.create(:project, :next_build_at => Time.now - 10.seconds)
    build_not_due_project = FactoryGirl.create(:project, :next_build_at => Time.now + 1.hour)
    undue_but_forced_project = FactoryGirl.create(:project, :next_build_at => Time.now + 1.hour, :build_requested => true)
    Project.projects_to_build.should include(new_project)
    Project.projects_to_build.should include(build_due_project)
    Project.projects_to_build.should include(undue_but_forced_project)
    Project.projects_to_build.should_not include(build_not_due_project)
  end

  it "evaluates now every time while picking the projects to build" do
    Project.projects_to_build
    Environment.should_receive(:now).and_return(Time.now)
    Project.projects_to_build
  end

  describe "activity" do
    let(:project){FactoryGirl.create(:project)}

    ['passed', 'failed', 'timeout'].each do |status|
      it "is Sleeping if no build is currently happening and if the last build #{status}" do
        FactoryGirl.create(:build, :project => project, :status => status)
        project.activity.should == 'Sleeping'
      end
    end

    it "is Building if a build is currently happening" do
      FactoryGirl.create(:build, :project => project, :status => 'building')
      project.activity.should == 'Building'
    end

    it "is Unknown for any status" do
      FactoryGirl.create(:build, :project => project, :status => 'foo bar')
      project.activity.should == 'Unknown'
    end
  end

  describe "cctray project status" do
    let(:project){FactoryGirl.create(:project)}

    {'passed' => 'Success', 'failed' => 'Failure', 'timeout' => 'Failure'}.each do |status, message|
      it "is '#{message}' when the last build '#{status}'" do
        FactoryGirl.create(:build, :project => project, :status => status)
        project.map_to_cctray_project_status.should == message
      end

      it "is '#{message}' when the last build is building & the second to last '#{status}'" do
        FactoryGirl.create(:build, :project => project, :status => status, :number => 10)
        FactoryGirl.create(:build, :project => project, :status => 'building', :number => 11)
        project.map_to_cctray_project_status.should == message
      end
    end
  end

  context "removing a failed add" do
    it "if the checkout fails" do
      Repository.stub(:new).and_return(mock(:repository, :checkout => false))
      project = FactoryGirl.create(:project)
      FileUtils.should_receive(:rm_rf).with(project.path)
      project.checkout
    end

    it "if the checkout raises an error" do
      repository = mock(:repository)
      repository.stub(:checkout).and_raise('an error')
      Repository.stub(:new).and_return(repository)
      project = FactoryGirl.create(:project)
      FileUtils.should_receive(:rm_rf).with(project.path)
      lambda {
        project.checkout
      }.should raise_error
    end
  end

  describe "github" do
    it "doesn't think random urls are on git" do
      FactoryGirl.create(:project, :url => 'git://somewhereelse.com/repo.git').github_url.should be_nil
    end

    it "detects a git protocol url" do
      FactoryGirl.create(:project, :url => 'git://github.com/some_user/some_repo.git').github_url.should == 'http://github.com/some_user/some_repo'
    end

    it "detects an http url" do
      FactoryGirl.create(:project, :url => 'http://github.com/some_user/some_repo.git').github_url.should == 'http://github.com/some_user/some_repo'
    end

    it "detects an https url" do
      FactoryGirl.create(:project, :url => 'https://github.com/some_user/some_repo.git').github_url.should == 'https://github.com/some_user/some_repo'
    end

    it "detects ssh accessed url" do
      FactoryGirl.create(:project, :url => 'git@github.com:some_user/some_repo.git').github_url.should == 'http://github.com/some_user/some_repo'
    end
  end
end
