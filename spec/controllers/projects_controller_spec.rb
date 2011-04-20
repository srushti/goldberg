require "spec_helper"

describe ProjectsController do
  it "loads one project" do
    project = Factory.create(:project, :name => 'some_project')
    get :show, :project_name => project.name
    response.should be_ok
    assigns[:project].should == project
  end

  it "allows forcing a build" do
    project = Factory.create(:project, :name => 'some_project')
    @request.env['HTTP_REFERER'] = 'http://referer/'
    post :force, :project_name => project.name
    response.should redirect_to('http://referer/')
    project.reload.should be_build_requested
  end

  [{:action => :show, :method => :get, :params => {:project_name => 'unknown_project'}}, {:action => :force, :method => :post, :params => {:project_name => 'unknown_project'}}].each do |entry|
    it "gives a 404 when an unknown project is requested for #{entry[:url]}" do
      Factory.create(:project, :name => 'existing_project')
      send(entry[:method], entry[:action], entry[:params])
      response.should be_not_found
    end
  end
end

