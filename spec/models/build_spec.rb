require "spec_helper"

describe Build do
  it "is able to fake a build" do
    nil_build = Build.null
    nil_build.should be_nil_build
    nil_build.revision.should == ""
    nil_build.number.should == 0
    nil_build.status.should == "not available"
    nil_build.build_log.should == ""
    nil_build.time.should be_nil
  end

  it "is not a nil build" do
    Build.new.should_not be_nil_build
  end

  it "sorts correctly" do
    builds = [10, 9, 1, 500].map{|i| FactoryGirl.create(:build, :number => i)}
    builds.sort.map(&:number).map(&:to_i).should == [1, 9, 10, 500]
  end

  it "is able to read the build log file to retrieve associated log" do
    build = FactoryGirl.build(:build)
    Environment.should_receive(:file_exist?).with(build.build_log_path).and_return(true)
    Environment.should_receive(:read_file).with(build.build_log_path).and_return("build_log")
    build.build_log.should == "build_log"
  end

  context "paths" do
    it "knows where to store the build artefacts on the file system" do
      project = FactoryGirl.build(:project, :name => "name")
      build = FactoryGirl.build(:build, :project => project, :number => 5)
      build.path.should == File.join(project.path, "builds", "5")
    end

    [:change_list, :build_log].each do |artefact|
      it "appends build number to the project path to create a path for #{artefact}" do
        project = FactoryGirl.build(:project, :name => "name")
        build = FactoryGirl.build(:build, :project => project, :number => 5)
        build.send("#{artefact}_path").should == File.join(project.path, "builds", "5", artefact.to_s)
      end
    end
  end

  context "after create" do
    it "creates a directory for storing build artefacts" do
      project = FactoryGirl.build(:project, :name => 'ooga')
      build = FactoryGirl.build(:build, :project => project, :number => 5)
      FileUtils.should_receive(:mkdir_p).with(build.path)
      build.save.should be_true
    end
  end

  context "before create" do
    it "updates the revision of the build if it is blank" do
      project = FactoryGirl.build(:project, :name => 'ooga')
      build = FactoryGirl.build(:build, :project => project, :number => 5, :revision => nil)
      project.repository.should_receive(:revision).and_return("new_sha")
      build.save
      build.reload
      build.revision.should == "new_sha"
    end

    it "does not update the build revision if it is already set" do
      project = FactoryGirl.build(:project, :name => 'ooga')
      build = FactoryGirl.build(:build, :project => project, :number => 5, :revision => "some_sha")
      build.save
      build.reload
      build.revision.should == "some_sha"
    end
  end

  context "changes" do
    it "writes a file with all the changes since the previous build" do
      project = FactoryGirl.build(:project, :name => 'ooga')
      build = FactoryGirl.build(:build, :project => project, :number => 5, :previous_build_revision => "old_sha", :revision => "new_sha")
      project.repository.should_receive(:change_list).with("old_sha", "new_sha").and_return("changes")
      file = mock(File)
      file.should_receive(:write).with("changes")
      File.should_receive(:open).with(build.change_list_path, "w+").and_yield(file)
      build.persist_change_list
    end
  end

  context "run" do
    let(:project) { FactoryGirl.build(:project) }
    let(:build) { FactoryGirl.create(:build, :number => 1, :project => project, :ruby => '1.9.2') }

    before(:each) do
      build.stub(:before_build)
      Environment.stub(:system)
    end

    it "executes in a clean environment" do
      pending "Need to write spec to make sure all code is getting executed within Bundle.with_clean_env"
    end

    describe 'timeout' do
      it "reports when the build hasn't exceeded the timeout" do
        config = Project::Configuration.new.tap{|config| config.timeout = 3.minutes}
        project.stub(:config).and_return(config)
        now = DateTime.now
        DateTime.stub(:now).and_return(now)
        build.exceeded_timeout?(now - 179.seconds).should == false
      end

      it "reports when the build has exceeded the timeout" do
        config = Project::Configuration.new.tap{|config| config.timeout = 3.minutes}
        project.stub(:config).and_return(config)
        now = DateTime.now
        DateTime.stub(:now).and_return(now)
        build.exceeded_timeout?(now - 181.seconds).should == true
      end

      it "doesn't timeout if it was configured as such" do
        config = Project::Configuration.new.tap{|config| config.timeout = Project::Configuration::NO_TIMEOUT}
        project.stub(:config).and_return(config)
        build.exceeded_timeout?(DateTime.now - 2.days).should == false
      end
    end

    it "performs prebuild setup before building the project" do
      Bundler.stub(:with_clean_env)
      build.should_receive(:before_build)
      build.run
    end

    it "runs the build command" do
      config = Project::Configuration.new
      project.stub(:config).and_return(config)
      build.environment_string = "FOO=bar"
      config.nice = 5
      expect_command("script/goldberg-build '#{project.name}' '1.9.2' '#{ENV['HOME']}/.goldberg/projects/#{project.name}/code' '#{ENV['HOME']}/.goldberg/projects/#{project.name}/builds/1/build_log' '#{ENV['HOME']}/.goldberg/projects/#{project.name}/builds/1/artefacts' '5' 'FOO=bar' '' rake default",
        :running? => false, :fork => nil, :success? => true
      )
      build.run
    end

    it "sets build status to failed if the build command succeeds" do
      Command.stub(:new).and_return(mock(Command, :execute => true, :running? => false, :fork => nil, :success? => true, :start_time => DateTime.now))
      build.run
      build.status.should == "passed"
    end

    it "sets build status to failed if the build command fails" do
      Command.stub(:new).and_return(mock(:command, :execute => true, :running? => false, :fork => nil, :success? => false, :start_time => DateTime.now))
      build.run
      build.status.should == "failed"
    end
  end

  context "before build" do
    it "sets build status to 'building' and persist the change list" do
      build = FactoryGirl.build(:build)
      build.should_receive(:persist_change_list)
      build.before_build
      build.reload.status.should == 'building'
    end
  end

  context "artefacts" do
    let(:build) { FactoryGirl.create(:build) }

    it "if the folder exists" do
      Environment.should_receive(:exist?).with(build.artefacts_path).and_return(true)
      Dir.stub(:entries).with(build.artefacts_path).and_return(['.', '..', 'entry1', 'entry2'])
      build.artefacts.should == ['entry1', 'entry2']
    end

    it "if the folder doesn't exist" do
      Environment.should_receive(:exist?).with(build.artefacts_path).and_return(false)
      build.artefacts.should == []
    end
  end

  it "cancels build" do
    build = FactoryGirl.create(:build)
    build.cancel
    build.should be_cancelled
  end

  describe "duration" do
    before(:each) do
      @now = Time.now
      Time.stub(:now).and_return(@now)
    end

    it "calculates the build's duration as being between created_at & updated_at" do
      build = FactoryGirl.create(:build, status: 'building')
      build.update_column(:created_at, @now - 3.minutes)
      expect(build.duration.to_i).to eq(3.minutes.to_i)
    end

    ['passed', 'failed', 'timeout', 'cancelled'].each do |status|
      it "calculates the build's duration when the status is #{status} to be time to now" do
        build = FactoryGirl.create(:build, status: status)
        build.update_column(:updated_at, @now - 2.days)
        build.update_column(:created_at, @now - 3.days)
        expect(build.duration.to_i).to eq(1.day.to_i)
      end
    end
  end
end
