require "spec_helper"

describe HomeController do
  it "loads all projects" do
    projects = []
    Project.should_receive(:all).and_return(projects)
    get :index
    response.should be_ok
    assigns[:projects].should == projects
  end

  it "generates the cc feed" do
    projects = [mock('project')]
    Project.should_receive(:all).and_return(projects)
    get :ccfeed, :format => :xml
    response.should be_ok
    response.body.should be_empty
    assigns[:projects].should == projects
  end
end
