require "spec_helper"

describe HookRunner do
  let(:project) { mock }
  let(:build) { mock }

  it "should be able to execute callbacks on an object implementing execute" do
    foo = mock
    foo.should_receive(:respond_to?).with(:execute).and_return(true)
    foo.should_receive(:execute).with(build, project)
    HookRunner.new(foo).execute(build, project)
  end

  it "should be able to execute a procedure" do
    a = false
    foo = Proc.new { a = true }
    HookRunner.new(foo).execute(build, project)
    a.should be_true
  end

  it "should be able to execute a list of commands" do
    a = 0
    foo = Proc.new { a = a + 1 }
    HookRunner.new([foo, foo]).execute(build, project)
    a.should == 2
  end
end
