require "spec_helper"

describe ProjectsController do
  it "loads one project" do
    project = mock(Project, :name => "some_project")
    Project.should_receive(:find_by_name).with(project.name).and_return(project)
    get :show, :id => project.name
    response.should be_ok
    assigns[:project].should == project
  end

  it "allows forcing a build" do
    project = mock(Project, :name => "name")
    Project.should_receive(:find_by_name).with(project.name).and_return(project)
    project.should_receive(:force_build)
    @request.env['HTTP_REFERER'] = 'http://referer/'
    post :force, :project_id => project.name
    response.should redirect_to('http://referer/')
  end

  [{:action => :show, :method => :get, :params => {:id => 'unknown_project'}}, {:action => :force, :method => :post, :params => {:project_id => 'unknown_project'}}].each do |entry|
    it "gives a 404 when an unknown project is requested for #{entry[:url]}" do
      project = mock(Project, :name => 'existing_project')
      Project.stub!(:all).and_return([project])
      send(entry[:method], entry[:action], entry[:params])
      response.should be_not_found
    end
  end
end

