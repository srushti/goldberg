require "spec_helper"

describe HomeController do
  [:index, :projects_partial].each do |action|
    describe action do
      it "loads all projects" do
        projects = []
        Project.should_receive(:all).and_return(projects)
        get action
        assigns[:grouped_projects].should == {}
      end

      it "sorts the projects by most recent activity" do
        old_project = Factory(:project)
        new_project = Factory(:project)
        old_build = Factory(:build, :project => old_project)
        new_build = Factory(:build, :project => new_project)
        old_build.update_attributes(:updated_at => 2.days.ago)
        new_build.update_attributes(:updated_at => 1.day.ago)
        get action
        assigns[:grouped_projects].should == { 'default' => [new_project, old_project]}
      end

      it "can sort projects with no latest build" do
        previously_built_project = mock('project', :group => 'default')
        real_build = mock('build')
        real_build.should_receive('updated_at').and_return(DateTime.now)
        previously_built_project.should_receive(:latest_build).and_return(real_build)
        project_with_no_build = mock('project', :group => 'default')
        project_with_no_build.should_receive(:latest_build).and_return(Build.null)
        Project.should_receive(:all).and_return([previously_built_project, project_with_no_build])
        get action
        assigns[:grouped_projects].should == { 'default' => [project_with_no_build, previously_built_project] }
      end

      it "groups projects" do
        first_project = mock(:one, :group => 'something', :latest_build => mock(:build_one, :updated_at => nil))
        second_project = mock(:two, :group => 'default', :latest_build => mock(:build_one, :updated_at => nil))
        Project.should_receive(:all).and_return([first_project, second_project])
        get action
        assigns[:grouped_projects].should == {'something' => [first_project], 'default' => [second_project]}
      end

      it "returns just one group" do
        first_project = mock(:one, :group => 'something', :latest_build => mock(:build_one, :updated_at => nil))
        second_project = mock(:two, :group => 'default', :latest_build => mock(:build_one, :updated_at => nil))
        Project.should_receive(:all).and_return([first_project, second_project])
        get action, :group_name => 'something'
        assigns[:grouped_projects].should == {'something' => [first_project]}
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

  after(:each) do
    response.should be_ok
  end
end
