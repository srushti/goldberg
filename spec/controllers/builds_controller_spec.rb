require "spec_helper"

describe BuildsController do
  it "loads one build" do
    project = Factory.create(:project, :name => "name")
    build = Factory.create(:build, :project => project, :number => 10)
    get :show, :project_id => project.name, :id => build.id
    
    response.should be_http_ok
    assigns[:project].should == project
    assigns[:build].should == build
  end
end

