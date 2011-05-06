require "spec_helper"

describe BuildPostProcessor do
  let(:project) { mock }

  context "on successfull build" do
    let(:build) { OpenStruct.new(:status => 'passed') }

    it "executes build completion callbacks" do
      callback_tester = mock
      configuration = ProjectConfig.new
      configuration.on_build_completion do |build_param,project_param|
        callback_tester.test_call(build_param,project_param)
      end
      callback_tester.should_receive(:test_call).with(build, project)
      BuildPostProcessor.new(configuration).execute(build, project)
    end

    it "does not execute build failure callbacks" do
      callback_tester = mock
      configuration = ProjectConfig.new
      configuration.on_build_failure do |build_param,project_param|
        callback_tester.test_call(build_param,project_param)
      end
      callback_tester.should_not_receive(:test_call).with(build, project)
      BuildPostProcessor.new(configuration).execute(build, project)
    end

    it "should executes build success callbacks" do
      callback_tester = mock
      configuration = ProjectConfig.new
      configuration.on_build_success do |build_param,project_param|
        callback_tester.test_call(build_param,project_param)
      end
      callback_tester.should_receive(:test_call).with(build, project)
      BuildPostProcessor.new(configuration).execute(build, project)
    end
  end

  context "on failed build" do
    let(:failed_build) { OpenStruct.new(:status => 'failed') }
    it "executes build completion callbacks" do
      callback_tester = mock
      configuration = ProjectConfig.new
      configuration.on_build_completion do |build_param,project_param|
        callback_tester.test_call(build_param,project_param)
      end
      callback_tester.should_receive(:test_call).with(failed_build, project)
      BuildPostProcessor.new(configuration).execute(failed_build, project)
    end
    
    it "executes build failure callbacks" do
      callback_tester = mock
      configuration = ProjectConfig.new
      configuration.on_build_failure do |build_param,project_param|
        callback_tester.test_call(build_param,project_param)
      end
      callback_tester.should_receive(:test_call).with(failed_build, project)
      BuildPostProcessor.new(configuration).execute(failed_build, project)
    end

    it "does not execute build success callbacks" do
      callback_tester = mock
      configuration = ProjectConfig.new
      configuration.on_build_success do |build_param,project_param|
        callback_tester.test_call(build_param,project_param)
      end
      callback_tester.should_not_receive(:test_call).with(failed_build, project)
      BuildPostProcessor.new(configuration).execute(failed_build, project)
    end
  end
end
