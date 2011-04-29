require "spec_helper"

describe Paths do
  context "projects" do
    it "creates the goldberg path if it doesn't exist and returns it" do
      File.stub!(:exist?).and_return(true)
      Env.should_receive(:[]).with('GOLDBERG_PATH').and_return(nil)
      Env.should_receive(:[]).with('HOME').and_return("path_to_home")
      Paths.projects.should == 'path_to_home/.goldberg/projects'
    end

    it "creates the goldberg path using the environment variable if defined" do
      File.stub!(:exist?).and_return(true)
      Env.should_receive(:[]).with('GOLDBERG_PATH').and_return('overridden_goldberg_path')
      Paths.projects.should == 'overridden_goldberg_path/projects'
    end
  end

  context "pid" do
    it "creates the pid directory if it doesn't exist" do
      File.stub!(:exist?).and_return(false)
      FileUtils.should_receive(:mkdir_p).and_return(true)
      Env.should_receive(:[]).with('GOLDBERG_PATH').and_return(nil)
      Env.should_receive(:[]).with('HOME').and_return("path_to_home")
      Paths.pid.should == 'path_to_home/.goldberg/pids/goldberg.pid'
    end
  end
end
