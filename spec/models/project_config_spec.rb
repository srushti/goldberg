require 'spec_helper'

describe ProjectConfig do
  context "default value" do
    let(:config) { ProjectConfig.new }

    it "for build frequency should be 20 seconds" do
      config.frequency.should == 20
    end

    it "environment variables should be an empty hash" do
      config.environment_variables.should == {}
      config.environment_string.should == ""
    end

    it "should have no after_build hook set" do
      config.after_build.should == []
    end
  end

  context "setting values" do
    it "should be able to add environment variables" do
      c = Project.configure do |config|
        config.environment_variables.update("FOO" => "bar")
      end
      c.environment_variables.should == { "FOO" => "bar" }
      c.environment_string.should == "FOO=bar"
    end

    it "should be able to store after_build commands" do
      foo = mock
      c = Project.configure do |config|
        config.after_build foo
      end
      c.after_build.should == [foo]
    end
  end
end
