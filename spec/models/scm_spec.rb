require 'spec_helper'

describe Scm do
  describe "provider" do
    it "chooses the given provider by name " do
      Scm.provider("git").should == Scm::Git
      Scm.provider("svn").should == Scm::Svn
    end
  end
end
