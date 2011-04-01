require "spec_helper"

describe BuildsController do
  it "loads one build" do
    project = Factory.create(:project, :name => "name")
    build = project.builds.create(:number => 10)
    get :show, :project_id => project.name, :id => build.id
    assigns[:project].should == project
    assigns[:build].should == build
  end
end

