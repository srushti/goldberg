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
    response.should redirect_to(:back)
    project.reload.should be_build_requested
  end

  [{:action => :show, :method => :get, :params => {:project_name => 'unknown_project'}}, {:action => :force, :method => :post, :params => {:project_name => 'unknown_project'}}].each do |entry|
    it "gives a 404 when an unknown project is requested for #{entry[:url]}" do
      Factory.create(:project, :name => 'existing_project')
      send(entry[:method], entry[:action], entry[:params])
      response.should be_not_found
    end
  end

  it "gives a json representation of all projects" do
    project = Factory(:project, :name => 'project1')
    Factory(:build, :status => 'passed', :project => project)
    get :index, :format => 'json'
    response.should be_ok
    builds_hash = JSON.parse(response.body)
    builds_hash[0]['project']['name'].should == 'project1'
    builds_hash[0]['project']['activity'].should == 'Sleeping'
    builds_hash[0]['project']['last_complete_build_status'].should == 'passed'
  end

  {'passed' => 'passed', 'failed' => 'failed', 'timeout' => 'failed', 'not available' => 'unknown'}.each do |status, filename|
    it "loads the #{filename} badge when the status is #{status}" do
      project = Factory(:project)
      build = Factory(:build, :project => project, :status => status)
      @controller.should_receive(:send_file).with(File.join(Rails.public_path, "images/badge/#{filename}.png"), anything)
      get :show, :project_name => project.name, :format => 'png'
    end
  end
end
