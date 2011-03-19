require "spec_helper"

describe 'home/ccfeed.xml.haml' do
  it "generates the cc feed" do
    now = Time.now
    build = mock('build')
    projects = [mock('project', :name => 'name', :last_built_at => now, :latest_build => build, :map_to_cctray_project_status => 'Success')]
    assign(:projects, projects)
    render
    expected_report = "<Projects>\n<Project activity='Sleeping' lastBuildStatus='Success' lastBuildTime='#{now}' name='name' nextBuildTime='#{now + 20}' webUrl='/projects/name'></Project>\n</Projects>\n"
    rendered.should == expected_report
  end
end

