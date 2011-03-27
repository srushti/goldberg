require 'spec_helper'

describe ApplicationHelper do
  it "should replace white spaces in build status with underscore" do
    helper.project_status("project passed").should == "project_passed"
  end
end
