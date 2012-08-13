require 'spec_helper'

describe ApplicationHelper do
  it "replaces white spaces in build status with underscore" do
    helper.project_status(mock(Project, :latest_build_status => 'project passed')).should == "project_passed"
    helper.build_status(mock(Build, :status => 'build passed')).should == "build_passed"
  end

  it "reports on unknown status" do
    helper.project_status(mock(Project, :latest_build_status => nil)).should == 'unknown'
  end

  it "formats timestamp" do
    helper.format_timestamp(2.days.ago).should == "<span class=\"timestamp\" title=\"#{2.days.ago.strftime('%a, %Y/%m/%d %I:%M%p %Z')}\">2 days ago</span>"
  end

  it "formats a nil as an empty string timestamp" do
    helper.format_timestamp(nil).should == ''
  end
end
