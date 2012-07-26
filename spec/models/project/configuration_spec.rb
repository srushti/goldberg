require 'spec_helper'

describe Project::Configuration do
  let(:config) { Project::Configuration.new }

  context "default value" do
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

  context "environment variables" do
    it "are settable" do
      config.environment_variables.update("FOO" => "bar")
      config.environment_variables.should == { "FOO" => "bar" }
    end

    it "can be merged with already set environment variables" do
      config.environment_variables = { "foo" => 1, "bar" => 2 }
      config.environment_variables = { "bar" => 3, "baz" => 4 }
      config.environment_variables.should == { "foo" => 1, "bar" => 3, "baz" => 4 }
    end

    it "get formatted into a string" do
      config.environment_variables = { "foo" => 1, "bar" => 2 }
      config.environment_string.should == "foo=1 bar=2"
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

  describe 'ruby_version' do
    it "uses the RUBY_PATCHLEVEL when it's MRI" do
      Environment.stub(:ruby_engine).and_return('ruby')
      Environment.stub(:ruby_version).and_return('4.2.4')
      Environment.stub(:ruby_patchlevel).and_return('2')
      Project::Configuration.new.ruby_version.should == '4.2.4-p2'
    end

    it "uses the JRUBY_VERSION if it's jruby" do
      Environment.stub(:ruby_engine).and_return('jruby')
      Environment.stub(:jruby_version).and_return('4.2')
      Project::Configuration.new.ruby_version.should == 'jruby-4.2'
    end

    it "just use the RUBY_VERSION with nothing else otherwise" do
      Environment.stub(:ruby_engine).and_return('something else')
      Environment.stub(:ruby_version).and_return('something_else')
      Project::Configuration.new.ruby_version.should == 'something_else'
    end
  end
end
