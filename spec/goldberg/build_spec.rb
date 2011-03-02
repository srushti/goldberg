require "spec_helper"

module Goldberg
  describe Build do
    it "gives all builds" do
      File.should_receive(:exist?).with('builds_path').and_return(true)
      Dir.should_receive(:entries).with('builds_path').and_return(['.', '..', '9', '10', '11'])
      (9..11).each do |i|
        File.should_receive(:directory?).with("builds_path/#{i.to_s}").and_return(true)
      end
      Build.all(mock(Project, :builds_path => 'builds_path')).should =~ [Build.new('builds_path/9'), Build.new('builds_path/10'), Build.new('builds_path/11')]
    end

    it "should return the version" do
      build = Build.new('/projects/name/builds/latest')
      File.stub!(:exist?).with('/projects/name/builds/latest/build_version').and_return(true)
      Environment.should_receive(:read_file).with('/projects/name/builds/latest/build_version')
      build.version
    end

    it "should be able to fake the last version" do
      Build.null.version.should == 'HEAD'
      Build.null.should be_null
    end

    it "reports the status of the build" do
      File.should_receive(:exist?).with('some_path/name/builds/latest/build_status').and_return(true)
      Environment.should_receive(:read_file).with('some_path/name/builds/latest/build_status').and_return('true')
      Build.new('some_path/name/builds/latest').status.should == 'passed'
    end

    it "should return the build time" do
      build = Build.new("some_path/name/builds/2")
      now = Time.now
      File.should_receive(:ctime).with('some_path/name/builds/2/build_status').and_return(now)
      build.timestamp.should == now
    end
  end
end
