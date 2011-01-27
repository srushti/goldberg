require 'spec_helper'

module GoldbergApi
  describe Application do
    it "should flap wings" do
      projects = [1, 2].map{|i| mock("project#{i}", :name => "name#{i}", :status => "status#{i}")}
      Goldberg::Project.should_receive(:all).and_return(projects)
      get '/'
      last_response.body.should include "name1 status1 name2 status2"
    end
  end
end
