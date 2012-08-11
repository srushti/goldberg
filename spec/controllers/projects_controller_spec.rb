require "spec_helper"

describe ProjectsController do
  it "loads one project" do
    project = FactoryGirl.create(:project, :name => 'some_project')
    get :show, :project_name => project.name
    response.should be_ok
    assigns[:project].should == project
  end

  it "allows forcing a build" do
    project = FactoryGirl.create(:project, :name => 'some_project')
    @request.env['HTTP_REFERER'] = 'http://referer/'
    post :force, :project_name => project.name
    response.should redirect_to(:back)
    project.reload.should be_build_requested
  end

  [{:action => :show, :method => :get, :params => {:project_name => 'unknown_project'}}, {:action => :force, :method => :post, :params => {:project_name => 'unknown_project'}}].each do |entry|
    it "gives a 404 when an unknown project is requested for #{entry[:url]}" do
      FactoryGirl.create(:project, :name => 'existing_project')
      send(entry[:method], entry[:action], entry[:params])
      response.should be_not_found
    end
  end

  describe "gives a json representation of" do
    let!(:project) do
      FactoryGirl.create(:project, :name => 'project1').tap do |project|
        FactoryGirl.create(:build, :status => 'passed', :project => project, :number => 123)
      end
    end

    it "all projects" do
      get :index, :format => 'json'
      response.should be_ok
      projects_hash = JSON.parse(response.body)
      projects_hash[0]['project']['name'].should == 'project1'
      projects_hash[0]['project']['activity'].should == 'Sleeping'
      projects_hash[0]['project']['last_complete_build_status'].should == 'passed'
      projects_hash[0]['project']['last_complete_build_number'].should == 123
    end

    it "one project" do
      get :show, :project_name => project.name, :format => 'json'
      response.should be_ok
      project_hash = JSON.parse(response.body)
      project_hash['project']['name'].should == 'project1'
      project_hash['project']['activity'].should == 'Sleeping'
      project_hash['project']['last_complete_build_status'].should == 'passed'
      project_hash['project']['last_complete_build_number'].should == 123
    end
  end

  {'passed' => 'passed', 'failed' => 'failed', 'timeout' => 'failed', 'not available' => 'unknown'}.each do |status, filename|
    it "loads the #{filename} badge when the status is #{status}" do
      project = FactoryGirl.create(:project)
      build = FactoryGirl.create(:build, :project => project, :status => status)
      @controller.should_receive(:send_file).with(File.join(Rails.public_path, "images/badge/#{filename}.png"), anything)
      get :show, :project_name => project.name, :format => 'png'
    end
  end
end
