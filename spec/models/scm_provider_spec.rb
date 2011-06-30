require 'spec_helper'

describe ScmProvider do
  describe "provider" do
    it "chooses the given provider by name " do
      ScmProvider.provider("git").should == ScmProvider::Git
      ScmProvider.provider("svn").should == ScmProvider::Svn
    end
  end
end
