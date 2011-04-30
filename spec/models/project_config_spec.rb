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
  end

  context "setting values" do
    
    it "should be able to add environment variables" do
      c = Project.configure do |config|
        config.environment_variables.update("FOO" => "bar")
      end
      c.environment_variables.should == { "FOO" => "bar" }
      c.environment_string.should == "FOO=bar"
    end
  end
end
