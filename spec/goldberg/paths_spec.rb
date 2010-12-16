require "spec_helper"

describe Goldberg::Paths do
  it "creates the goldberg path if it doesn't exist and returns it" do
    File.stub!(:exist?).and_return(true)
    Env.should_receive(:[]).with('GOLDBERG_PATH').and_return(nil)
    Env.should_receive(:[]).with('HOME').and_return("path_to_home")
    Goldberg::Paths.projects.should == 'path_to_home/.goldberg/projects'
  end

  it "creates the goldberg path using the environment variable if defined" do
    File.stub!(:exist?).and_return(true)
    Env.should_receive(:[]).with('GOLDBERG_PATH').and_return('overridden_goldberg_path')
    Goldberg::Paths.projects.should == 'overridden_goldberg_path/projects'
  end
end

