require 'spec_helper'

describe Project::Configuration do
  context "default value" do
    let(:config) { Project::Configuration.new }

    it "for build frequency should be 20 seconds" do
      config.frequency.should == 20
    end

    it "environment variables should be an empty hash" do
      config.environment_variables.should == {}
      config.environment_string.should == ""
    end

    it "for niceness of the build process should be +0" do
      config.nice.should eq(0)
    end
    
    it "should have no callbacks set" do
      config.build_completion_callbacks.should == []
      config.build_failure_callbacks.should == []
      config.build_fixed_callbacks.should == []
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

  context "callbacks" do
    it "should be able to register build completion callbacks" do
      some_variable = nil
      configuration = Project.configure do |config|
        config.on_build_completion do
          some_variable = 'assigned'
        end
      end
      configuration.build_completion_callbacks.each(&:call)
      some_variable.should == 'assigned'
    end

    it "should be able to register build failure callbacks" do
      some_variable = nil
      configuration = Project.configure do |config|
        config.on_build_failure do
          some_variable = 'assigned'
        end
      end
      configuration.build_failure_callbacks.each(&:call)
      some_variable.should == 'assigned'
    end

    it "should be able to register red build passed callbacks" do
      some_variable = nil
      configuration = Project.configure do |config|
        config.on_build_fixed do
          some_variable = 'assigned'
        end
      end
      configuration.build_fixed_callbacks.each(&:call)
      some_variable.should == 'assigned'
    end

    it "should be able to register success callbacks" do
      some_variable = nil
      configuration = Project.configure do |config|
        config.on_build_success do
          some_variable = 'assigned'
        end
      end
      configuration.build_success_callbacks.each(&:call)
      some_variable.should == 'assigned'
    end
  end
end
