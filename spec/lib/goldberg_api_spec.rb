require 'spec_helper'

module GoldbergApi
  describe Application do
    it "lists all project" do
      projects = []
      projects << mock('project1', :name => 'name1', :status => 'passed', :build_log => 'log1')
      projects << mock('project2', :name => 'name2', :status => 'failed', :build_log => 'log2')
      Goldberg::Project.should_receive(:all).and_return(projects)
      projects.each {|project| project.should_receive(:last_built_at)}
      get '/'
      last_response.body.should include "name1"
      last_response.body.should include "name2"
    end

    it "gives the status & log of a project" do
      project = mock(Goldberg::Project, :name => "name", :status => 'passed', :build_log => "log")
      build = Goldberg::Build.null
      Goldberg::Project.should_receive(:all).and_return([project])
      Goldberg::Project.should_receive(:new).with(project.name).and_return(project)
      project.should_receive(:builds).and_return([build])
      get '/projects/name'
      last_response.body.should include project.name
      last_response.body.should include "passed"
      last_response.body.should include "log"
    end

    [{:url => '/projects/unknown_project', :method => :get}, {:url => '/projects/unknown_project/force', :method => :post}].each do |entry|
      it "gives a 404 when an unknown project is requested for #{entry[:url]}" do
        project = mock(Goldberg::Project, :name => 'existing_project')
        Goldberg::Project.stub!(:all).and_return([project])
        send(entry[:method], entry[:url])
        last_response.status.should == 404
      end
    end

    it "allows forcing a build" do
      project = mock(Goldberg::Project, :name => "name", :status => "status", :build_log => "log")
      Goldberg::Project.should_receive(:new).with(project.name).and_return(project)
      Goldberg::Project.should_receive(:all).and_return([project])
      project.should_receive(:force_build)
      post '/projects/name/force'
      last_response.should be_redirect
    end

    ['/cc.xml', '/XmlStatusReport.aspx', '/cctray.xml'].each do |route|
      it "loads the cruise control tray feed at #{route}" do
        now = Time.now
        build = mock('build')
        Goldberg::Project.should_receive(:all).and_return([mock('project', :name => 'name', :last_built_at => now, :latest_build => build, :map_to_cctray_project_status => 'Success')])
        get route
        expected_report = <<-EOXML
<Projects>
  <Project activity='Sleeping' lastBuildStatus='Success' lastBuildTime='#{now}' name='name' nextBuildTime='#{now + 20}' webUrl='/projects/name'></Project>
</Projects>
        EOXML
        last_response.body.should == expected_report
      end
    end
  end
end
