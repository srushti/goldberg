require 'spec_helper'

describe HomeHelper do
  {'building' => 'building.gif', 'not_available' => 'not_available.gif', 'cancelled' => 'cancelled.gif', 'passed' => 'passed.png', 'failed' => 'failed.png'}.each do |status, file_name|
    it "renders the status icon when the status is #{status}" do
      helper.stub(:image_tag).with(file_name, alt: status, title: status).and_return("the correct image tag")
      helper.project_status_image(status).should == 'the correct image tag'
    end
  end
end
