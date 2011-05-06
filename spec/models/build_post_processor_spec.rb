require "spec_helper"

describe BuildPostProcessor do
  let(:project) { mock }
  let(:build) { mock }

  it "should be able to execute callbacks on an object implementing execute" do
    callback_tester = mock
    configuration = ProjectConfig.new
    configuration.on_build_completion do |build,project|
      callback_tester.test_call(build,project)
    end
    callback_tester.should_receive(:test_call).with(build, project)
    BuildPostProcessor.new(configuration).execute(build, project)
  end
end
