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

      it "can sort projects with no latest build" do
        previously_built_project = mock('project')
        real_build = mock('build')
        real_build.should_receive('updated_at').and_return(DateTime.now)
        previously_built_project.should_receive(:latest_build).and_return(real_build)
        project_with_no_build = mock('project')
        project_with_no_build.should_receive(:latest_build).and_return(Build.null)
        Project.should_receive(:all).and_return([previously_built_project, project_with_no_build])
        controller.load_projects
        assigns[:projects].should == [project_with_no_build, previously_built_project]
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
