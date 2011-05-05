require "spec_helper"

describe BuildPostProcessor do
  let(:project) { mock }
  let(:build) { mock }

  it "should be able to execute callbacks on an object implementing execute" do
    callback = mock
    callback.should_receive(:respond_to?).with(:execute).and_return(true)
    callback.should_receive(:execute).with(build, project)
    BuildPostProcessor.new(callback).execute(build, project)
  end

  it "should be able to execute a procedure" do
    some_variable = false
    callback = Proc.new { some_variable = true }
    BuildPostProcessor.new(callback).execute(build, project)
    some_variable.should be_true
  end

  it "should be able to execute a list of commands" do
    some_variable = 0
    callback = Proc.new { some_variable = some_variable + 1 }
    BuildPostProcessor.new([callback, callback]).execute(build, project)
    some_variable.should == 2
  end
end
