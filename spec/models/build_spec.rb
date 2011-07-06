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
    builds = [10, 9, 1, 500].map{|i| Factory(:build, :number => i)}
    builds.sort.map(&:number).map(&:to_i).should == [1, 9, 10, 500]
  end

  it "is able to read the build log file to retrieve associated log" do
    build = Factory.build(:build)
    Environment.should_receive(:file_exist?).with(build.build_log_path).and_return(true)
    Environment.should_receive(:read_file).with(build.build_log_path).and_return("build_log")
    build.build_log.should == "build_log"
  end

  context "paths" do
    it "knows where to store the build artefacts on the file system" do
      project = Factory.build(:project, :name => "name")
      build = Factory.build(:build, :project => project, :number => 5)
      build.path.should == File.join(project.path, "builds", "5")
    end

    [:change_list, :build_log].each do |artefact|
      it "appends build number to the project path to create a path for #{artefact}" do
        project = Factory.build(:project, :name => "name")
        build = Factory.build(:build, :project => project, :number => 5)
        build.send("#{artefact}_path").should == File.join(project.path, "builds", "5", artefact.to_s)
      end
    end
  end

  context "after create" do
    it "creates a directory for storing build artefacts" do
      project = Factory.build(:project, :name => 'ooga')
      build = Factory.build(:build, :project => project, :number => 5)
      FileUtils.should_receive(:mkdir_p).with(build.path)
      build.save.should be_true
    end
  end

  context "before create" do
    it "updates the revision of the build if it is blank" do
      project = Factory.build(:project, :name => 'ooga')
      build = Factory.build(:build, :project => project, :number => 5, :revision => nil)
      project.repository.should_receive(:revision).and_return("new_sha")
      build.save
      build.reload
      build.revision.should == "new_sha"
    end

    it "does not update the build revision if it is already set" do
      project = Factory.build(:project, :name => 'ooga')
      build = Factory.build(:build, :project => project, :number => 5, :revision => "some_sha")
      build.save
      build.reload
      build.revision.should == "some_sha"
    end
  end

  context "changes" do
    it "writes a file with all the changes since the previous build" do
      project = Factory.build(:project, :name => 'ooga')
      build = Factory.build(:build, :project => project, :number => 5, :previous_build_revision => "old_sha", :revision => "new_sha")
      project.repository.should_receive(:change_list).with("old_sha", "new_sha").and_return("changes")
      file = mock(File)
      file.should_receive(:write).with("changes")
      File.should_receive(:open).with(build.change_list_path, "w+").and_yield(file)
      build.persist_change_list
    end
  end

  context "run" do
    let(:project) { Factory.build(:project) }
    let(:build) { Factory.create(:build, :number => 1, :project => project) }

    before(:each) do
      build.stub(:before_build)
      Environment.stub(:system)
    end

    it "executes in a clean environment" do
      pending "Need to write spec to make sure all code is getting executed within Bundle.with_clean_env"
    end

    it "performs prebuild setup before building the project" do
      Bundler.stub(:with_clean_env)
      build.should_receive(:before_build)
      build.run
    end

    it "resets the appropriate environment variables before executing the command to build the project" do
      Env.should_receive(:[]=).with('BUNDLE_GEMFILE', nil)
      Env.should_receive(:[]=).with('RUBYOPT', nil)
      build.stub!(:artefacts_path).and_return('artefacts path')
      Env.should_receive(:[]=).with('BUILD_ARTEFACTS', 'artefacts path')
      Env.should_receive(:[]=).with('BUILD_ARTIFACTS', 'artefacts path')
      Env.should_receive(:[]=).with('RAILS_ENV', nil)
      Command.stub!(:new).and_return(mock(:command, :running? => false, :execute => true, :fork => nil, :success? => nil))
      build.run
    end

    it "runs the build command" do
      config = Project::Configuration.new
      project.stub(:config).and_return(config)
      config.nice = 5
      expect_command("source #{Env['HOME']}/.rvm/scripts/rvm && rvm use --create @global && (gem list | grep bundler) || gem install bundler", :execute => true)
      expect_command("rvm rvmrc trust #{Env['HOME']}/.goldberg/projects/#{project.name}/code", :execute => true)
      expect_command("(source #{Env['HOME']}/.rvm/scripts/rvm && rvm use --create @goldberg-#{project.name} ; cd #{Env['HOME']}/.goldberg/projects/#{project.name}/code ;  nice -n 5 rake default) 1>>#{Env['HOME']}/.goldberg/projects/#{project.name}/builds/1/build_log 2>>#{Env['HOME']}/.goldberg/projects/#{project.name}/builds/1/build_log",
        :running? => false, :fork => nil, :success? => true
      )
      build.run
    end

    it "sets build status to failed if the build command succeeds" do
      Command.stub(:new).and_return(mock(Command, :execute => true, :running? => false, :fork => nil, :success? => true))
      build.run
      build.status.should == "passed"
    end

    it "sets build status to failed if the build command fails" do
      Command.stub!(:new).and_return(mock(:command, :execute => true, :running? => false, :fork => nil, :success? => false))
      build.run
      build.status.should == "failed"
    end
  end

  context "runs with" do
    let(:project) { Factory(:project) }
    let(:build) { Factory(:build, :number => 1, :project => project, :environment_string => "FOO=bar") }

    it "environment variables passed to the system command" do
      build.stub(:before_build)
      RVM.stub(:prepare_ruby)
      Command.stub!(:new).and_return(mock(:command, :execute => true, :running? => false, :fork => nil, :success? => true))
      build.run.should be_true
    end
  end

  context "before build" do
    it "sets build status to 'building' and persist the change list" do
      build = Factory.build(:build)
      build.should_receive(:persist_change_list)
      FileUtils.should_receive(:mkdir_p).with(build.artefacts_path)
      build.before_build
      build.reload.status.should == 'building'
    end
  end

  context "artefacts" do
    let(:build) { Factory(:build) }

    it "if the folder exists" do
      Environment.should_receive(:exist?).with(build.artefacts_path).and_return(true)
      Dir.stub!(:entries).with(build.artefacts_path).and_return(['.', '..', 'entry1', 'entry2'])
      build.artefacts.should == ['entry1', 'entry2']
    end

    it "if the folder doesn't exist" do
      Environment.should_receive(:exist?).with(build.artefacts_path).and_return(false)
      build.artefacts.should == []
    end
  end
end
