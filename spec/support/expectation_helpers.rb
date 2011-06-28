module Goldberg
  module ExpectationHelpers
    def expect_command(command, stubs = {})
      Command.should_receive(:new).with(command).and_return(command = mock(Command, stubs))
      command
    end
  end
end