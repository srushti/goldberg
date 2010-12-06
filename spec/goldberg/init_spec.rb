require "spec_helper"

describe Goldberg::Init do
  it "adds a new project" do
    Goldberg::CommandLine.stub!(:argv).and_return(['add', 'url', 'name'])
    Goldberg::Project.should_receive(:add).with(:url => 'url', :name => 'name')
    Goldberg::Init.new.run
  end
end

