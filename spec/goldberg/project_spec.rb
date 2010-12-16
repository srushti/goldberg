require "spec_helper"
module Goldberg
  describe Project do
    it "checks out a new git project" do
      Paths.stub!(:projects).and_return('some_path')
      Git.should_receive(:clone).with('git://some.url.git', 'some_project', :path => 'some_path')
      project = Project.add({:url => "git://some.url.git", :name => 'some_project'})
      project.name.should == 'some_project'
    end

    it "updates the project" do
      Paths.stub!(:projects).and_return('some_path')
      git = mock(Git)
      Git.should_receive(:open).with('some_path/name', anything).and_return(git)
      git.should_receive(:pull)
      Project.new('name').update
    end
  end
end
