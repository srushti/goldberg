require 'spec_helper'

describe HomeHelper do
  it "renders the status icon for building" do
    helper.stub!(:image_tag).with('building.gif', :alt => 'building', :title => 'building').and_return('the correct image tag')
    helper.project_status_image('building').should == 'the correct image tag'
  end

  it "renders the status icons for statuses other than building as well" do
    helper.stub!(:image_tag).with('other_status.png', :alt => 'other_status', :title => 'other_status').and_return('also the correct image tag')
    helper.project_status_image('other_status').should == 'also the correct image tag'
  end
end

