require 'spec_helper'

describe BuildsHelper do
  include BuildsHelper

  it "generates just the revision number if the project is not hosted on github" do
    build = FactoryGirl.create(:build, :revision => 'revision_number')
    revision_number_text(build).should == "revisi"
  end

  it "generates a github url if the project is hosted on github" do
    build = FactoryGirl.create(:build, :revision => 'revision_number', :project => FactoryGirl.create(:project, :url => 'http://github.com/owner/project'))
    revision_number_text(build).should include('http://github.com/owner/project/commit/revision_number')
  end
end
