require "spec_helper"

describe BuildPostProcessor do
  let(:project) { mock }
  let(:callback_tester) { mock }
  let(:configuration) { ProjectConfig.new }
  let(:previous_build_status){ mock }

  context "on successfull build" do
    let(:build) { OpenStruct.new(:status => 'passed') }

    it "executes build completion callbacks" do
      configuration.on_build_completion do |build_param, project_param|
        callback_tester.test_call(build_param, project_param)
      end
      callback_tester.should_receive(:test_call).with(build, project)
      BuildPostProcessor.new(configuration).execute(build, project, previous_build_status)
    end

    it "does not execute build failure callbacks" do
      configuration.on_build_failure do |build_param, project_param|
        callback_tester.test_call(build_param, project_param)
      end
      callback_tester.should_not_receive(:test_call).with(build, project)
      BuildPostProcessor.new(configuration).execute(build, project, previous_build_status)
    end

    it "executes build success callbacks" do
      configuration.on_build_success do |build_param, project_param|
        callback_tester.test_call(build_param, project_param)
      end
      callback_tester.should_receive(:test_call).with(build, project)
      BuildPostProcessor.new(configuration).execute(build, project, previous_build_status)
    end

    it "executes red to green callback if previous build status was failed" do
      previous_build_status = 'failed'
      configuration.on_red_to_green do |build_param, project_param|
        callback_tester.test_call(build_param, project_param)
      end
      callback_tester.should_receive(:test_call).with(build, project)
      BuildPostProcessor.new(configuration).execute(build, project, previous_build_status)
    end

    it "does not executes red to green callback if previous build status was not failed" do
      previous_build_status = 'anything but failed'
      configuration.on_red_to_green do |build_param, project_param|
        callback_tester.test_call(build_param, project_param)
      end
      callback_tester.should_not_receive(:test_call).with(build, project)
      BuildPostProcessor.new(configuration).execute(build, project, previous_build_status)
    end
  end

  context "on failed build" do
    let(:failed_build) { OpenStruct.new(:status => 'failed') }
    it "executes build completion callbacks" do
      configuration.on_build_completion do |build_param, project_param|
        callback_tester.test_call(build_param, project_param)
      end

      callback_tester.should_receive(:test_call).with(failed_build, project)
      
      BuildPostProcessor.new(configuration).execute(failed_build, project, previous_build_status)
    end

    it "executes build failure callbacks" do
      configuration.on_build_failure do |build_param, project_param|
        callback_tester.test_call(build_param, project_param)
      end

      callback_tester.should_receive(:test_call).with(failed_build, project)

      BuildPostProcessor.new(configuration).execute(failed_build, project, previous_build_status)
    end

    it "does not execute build success callbacks" do
      configuration.on_build_success do |build_param, project_param|
        callback_tester.test_call(build_param, project_param)
      end

      callback_tester.should_not_receive(:test_call).with(failed_build, project)

      BuildPostProcessor.new(configuration).execute(failed_build, project, previous_build_status)
    end
  end
end
