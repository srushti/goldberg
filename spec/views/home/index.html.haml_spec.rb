require "spec_helper"

describe 'home/index.html.haml' do
  it "lists all projects" do
    projects = []
    projects << mock('project1', :name => 'name1', :status => 'passed', :build_log => 'log1')
    projects << mock('project2', :name => 'name2', :status => 'failed', :build_log => 'log2')
    projects.each {|project| project.should_receive(:last_built_at)}
    assign(:projects, projects)
    render
    rendered.should include "name1"
    rendered.should include "name2"
  end
end

