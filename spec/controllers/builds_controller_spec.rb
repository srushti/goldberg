require "spec_helper"

describe BuildsController do
  it "loads one build" do
    build = mock(Build, :number => 10)
    project = mock(Project, :name => "name", :status => 'passed', :build_log => "log", :builds => [mock('another build', :number => 20), build])
    Project.should_receive(:new).with(project.name).and_return(project)
    get :show, :project_id => project.name, :id => build.number
    assigns[:project].should == project
    assigns[:build].should == build
  end
end

