require "spec_helper"

describe Init do
  it "adds a new project" do
    Project.should_receive(:add).with(:url => 'url', :name => 'name', :branch => 'master',:scm => 'git').and_return(true)
    Goldberg.logger.should_receive(:info).with('name successfully added.')
    Init.new.add('url', 'name', 'master', 'git')
  end

  it "adds a new project with a custom command" do
    Project.should_receive(:add).with(:url => 'url', :name => 'name', :branch => 'master',:scm => 'svn').and_return(true)
    Goldberg.logger.should_receive(:info).with('name successfully added.')
    Init.new.add('url', 'name', 'master', 'svn')
  end

  it "reports failure in adding a project" do
    Project.should_receive(:add).and_return(false)
    Goldberg.logger.should_receive(:info).with("There was problem adding the project.")
    Init.new.add('url', 'name', 'master','svn')
  end

  it "removes the specified project" do
    project = Factory(:project, :name => 'name')
    Goldberg.logger.should_receive(:info).with('name successfully removed.')
    Init.new.remove('name')
    Project.find_by_id(project.id).should_not be
  end

  it "fails gracefully if it can't find the project to remove" do
    Goldberg.logger.should_receive(:error).with("Project unknown does not exist.")
    Init.new.remove('unknown')
  end

  it "lists all projects" do
    project = Factory(:project, :name => 'a_project')
    Goldberg.logger.should_receive(:info).with(project.name)
    Init.new.list
  end

  it "continues on with the next project even if one build fails" do
    one = Factory(:project, :name => 'one')
    two = Factory(:project, :name => 'two')
    exception = Exception.new("An exception")
    one.stub!(:run_build).and_raise(exception)
    two.should_receive(:run_build)
    Project.stub!(:projects_to_build).and_return([one, two])
    Goldberg.logger.should_receive(:error).with("Build on project #{one.name} failed because of An exception")
    Goldberg.logger.should_receive(:error)
    Init.new.poll
  end
end
