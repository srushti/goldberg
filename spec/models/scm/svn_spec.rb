require 'spec_helper'

describe Scm::Svn do
  describe "author" do
    it "should use revision range provided" do
      Scm.provider("svn").author(['123','234']).should ==  "svn log -r123:234 | grep \"^[r\d]\" | awk '{print $3}'| uniq| tr \"\\n\" \" \""
    end
  end
end
