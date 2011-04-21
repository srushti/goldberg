require "spec_helper"

describe BuildsController do
  it "loads one build" do
    project = Factory.create(:project, :name => "name")
    build = Factory.create(:build, :project => project, :number => 10)
    get :show, :project_name => project.name, :build_number => build.number

    response.should be_http_ok
    assigns[:project].should == project
    assigns[:build].should == build
  end

  it "denotes an unknown project" do
    get :show, :project_name => 'random project', :build_number => 1
    response.should be_not_found
  end

  it "denotes an unknown build" do
    project = Factory.create(:project, :name => "name")
    get :show, :project_name => project.name, :build_number => 1
    response.should be_not_found
  end
end

