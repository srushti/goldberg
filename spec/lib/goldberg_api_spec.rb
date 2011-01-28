require 'spec_helper'

module GoldbergApi
  describe Application do
    it "lists all project" do
      projects = (1..2).map{|i| mock("project#{i}", :name => "name#{i}", :status => "status#{i}", :build_log => ["log#{i}"])}
      Goldberg::Project.should_receive(:all).and_return(projects)
      get '/'
      last_response.body.should include "name1 status1"
      last_response.body.should include "log1"
      last_response.body.should include "name2 status2"
      last_response.body.should include "log2"
    end

    it "gives the status & log of a project" do
      project = mock(Goldberg::Project, :name => "name", :status => "status", :build_log => ["log"])
      Goldberg::Project.should_receive(:new).with(project.name).and_return(project)
      get '/projects/name'
      last_response.body.should include "name status"
      last_response.body.should include "log"
    end

    it "allows forcing a build" do
      project = mock(Goldberg::Project, :name => "name", :status => "status", :build_log => ["log"])
      Goldberg::Project.should_receive(:new).twice.with(project.name).and_return(project)
      project.should_receive(:force_build)
      post '/projects/name/force'
      follow_redirect!
      last_response.body.should include "name status"
      last_response.body.should include "log"
    end
  end
end
