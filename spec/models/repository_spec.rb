require 'spec_helper'

describe Repository do
  let(:repo) { Repository.new("code_path", "git://github.com/c42/goldberg.git", "production","git") }
  it "checks out the code at the given path and return true on success" do
    expect_command("git clone --depth 1 git://github.com/c42/goldberg.git code_path --branch production", :execute => true)
    repo.checkout.should be_true
  end

  it "knows the sha of current revision" do
    expect_command("cd code_path && git rev-parse --verify HEAD", :execute_with_output => "random_sha\n")
    repo.revision.should == "random_sha"
  end

  context "author" do
    it "gets the author information from the scm in the code path" do
    expect_command("cd code_path && git show  -s  --pretty=\"format:%an\"  12345..4567| uniq| tr \"\\n\" \" \"", :execute_with_output => "surya")
    repo.author(["12345","4567"]).should == "surya"
    end
  end

  context "update" do
    it "updates the code at given location and return true if there are updates" do
      expect_command("cd code_path && git rev-parse --verify HEAD", :execute_with_output => "old_sha")
      expect_command("cd code_path && git rev-parse --verify HEAD", :execute_with_output => "new_sha")
      expect_command("cd code_path && git pull && git submodule init && git submodule update", :execute => true)
      repo.update.should be_true
    end

    it "returns false if code there were no updates" do
      expect_command("cd code_path && git rev-parse --verify HEAD", :execute_with_output => "old_sha")
      expect_command("cd code_path && git rev-parse --verify HEAD", :execute_with_output => "old_sha")
      expect_command("cd code_path && git pull && git submodule init && git submodule update", :execute => true)
      repo.update.should be_false
    end
  end

  context "change list" do
    it "retrieves a list of changes given two revisions" do
      expect_command("cd code_path && git whatchanged old_sha..new_sha --pretty=oneline --name-status", :execute_with_output => "change list")
      repo.change_list("old_sha", "new_sha").should == "change list"
    end

    it "returns empty change list if old sha is blank" do
      Command.any_instance.should_not_receive(:execute_with_output)
      repo.change_list(nil, "new_sha").should be_blank
    end

    it "retrieves a list of changes if old sha is present but new sha is blank" do
      expect_command("cd code_path && git whatchanged old_sha.. --pretty=oneline --name-status", :execute_with_output => "change list")
      repo.change_list("old_sha", nil).should == "change list"
    end
  end

  describe "check if file is versioned" do
    it "should return false if the file is not versioned" do
      expect_command("cd code_path && git checkout some_file 2>>/dev/null || echo 'not versioned'", :execute_with_output => "not versioned")
      repo.versioned?("some_file").should be_false
    end

    it "should return true if the file is versioned" do
      expect_command("cd code_path && git checkout some_file 2>>/dev/null || echo 'not versioned'", :execute_with_output => "")
      repo.versioned?("some_file").should be_true
    end
  end
end
