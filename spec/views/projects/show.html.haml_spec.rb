require "spec_helper"

describe 'projects/show.html.haml' do
  it "gives the status & log of a project" do
    project = mock(Project, :name => "name", :status => 'passed', :build_log => "log")
    build = Build.null
    project.should_receive(:builds).and_return([build])
    assign(:project, project)
    render
    rendered.should include project.name
    rendered.should include "passed"
    rendered.should include "log"
  end
end


