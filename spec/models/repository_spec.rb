require 'spec_helper'

describe Repository do
  let(:repo) { Repository.new("code_path", "url") }
  it "should checkout the code at the given path and return true on success" do
    Environment.should_receive(:system).with("git clone --depth 1 url code_path").and_return(true)
    repo.checkout.should be_true
  end
  
  it "should know the sha of current revision" do
    Environment.should_receive(:system_call_output).with("cd code_path && git rev-parse --verify HEAD").and_return("random_sha")
    repo.revision.should == "random_sha"
  end
  
  context "update" do
    it "should update the code at given location and return true if there are updates" do
      Environment.should_receive(:system_call_output).with("cd code_path && git rev-parse --verify HEAD").and_return("old_sha")
      Environment.should_receive(:system_call_output).with("cd code_path && git rev-parse --verify HEAD").and_return("new_sha")
      Environment.should_receive(:system).with("cd code_path && git pull").and_return(true)
      repo.update.should be_true
    end
    
    it "should return false if code there were no updates" do
      Environment.should_receive(:system_call_output).with("cd code_path && git rev-parse --verify HEAD").and_return("old_sha")
      Environment.should_receive(:system_call_output).with("cd code_path && git rev-parse --verify HEAD").and_return("old_sha")
      Environment.should_receive(:system).with("cd code_path && git pull").and_return(true)
      repo.update.should be_false
    end
  end
  
  context "change list" do
    it "should retrieve a list of changes given two revisions" do
      Environment.should_receive(:system_call_output).with("cd code_path && git whatchanged old_sha..new_sha --pretty=oneline --name-status").and_return("change list")
      repo.change_list("old_sha", "new_sha").should == "change list"
    end
    
    it "should return empty change list if old sha is blank" do
      Environment.should_not_receive(:system_call_output)
      repo.change_list(nil, "new_sha").should be_blank
    end
    
    it "should retrieve a list of changes if old sha is present but new sha is blank" do
      Environment.should_receive(:system_call_output).with("cd code_path && git whatchanged old_sha.. --pretty=oneline --name-status").and_return("change list")
      repo.change_list("old_sha", nil).should == "change list"
    end
  end
end
