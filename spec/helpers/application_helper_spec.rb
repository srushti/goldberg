require 'spec_helper'

describe ApplicationHelper do
  it "replaces white spaces in build status with underscore" do
    helper.project_status(mock(Project, :latest_build_status => 'project passed')).should == "project_passed"
    helper.build_status(mock(Build, :status => 'build passed')).should == "build_passed"
  end
end
