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
      Environment.should_receive(:read_file).with('/projects/name/builds/latest/build_version')
      build.version
    end
  end
end
