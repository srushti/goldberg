require "spec_helper"

describe Job do
  it "checks out a new git project" do
    Paths.stub!(:projects).and_return('some_path')
    Git.should_receive(:clone).with('git://some.url.git', 'some_project', :path => 'some_path')
    Job.add({:url => "git://some.url.git", :name => 'some_project'})
  end
end

