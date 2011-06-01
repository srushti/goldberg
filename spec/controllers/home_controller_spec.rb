require "spec_helper"

describe HomeController do
  [:index, :projects_partial].each do |action|
    describe action do
      it "loads all projects" do
        projects = []
        Project.should_receive(:all).and_return(projects)
        get action
        response.should be_ok
        assigns[:projects].should == projects
      end

      it "sorts the projects by most recent activity" do
        old_project = Factory(:project)
        new_project = Factory(:project)
        old_build = Factory(:build, :project => old_project)
        new_build = Factory(:build, :project => new_project)
        old_build.update_attributes(:updated_at => 2.days.ago)
        new_build.update_attributes(:updated_at => 1.day.ago)
        get action
        response.should be_ok
        assigns[:projects].should == [new_project, old_project]
      end
    end
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
