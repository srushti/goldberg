require 'spec_helper'

describe ScmProvider do
  describe "provider" do
    it "chooses git as the provider if url is a git repository" do
      ScmProvider.provider("git://github.com/c42/goldberg.git").should == ScmProvider::Git
    end
    it " chooses svn as the provider if url is a not git repository" do
      ScmProvider.provider("http://qrcode-rails.googlecode.com/svn/trunk/").should == ScmProvider::Svn
    end
  end
end
