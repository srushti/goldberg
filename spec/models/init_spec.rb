require "spec_helper"

describe Init do
  it "adds a new project" do
    CommandLine.stub!(:argv).and_return(['add', 'url', 'name'])
    Project.should_receive(:add).with(:url => 'url', :name => 'name')
    Init.new.run
  end
end

