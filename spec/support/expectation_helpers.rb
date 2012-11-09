module Goldberg
  module ExpectationHelpers
    def expect_command(command, stubs = {})
      command.tap{|c| Command.should_receive(:new).with(c).and_return(c = mock(Command, { start_time: DateTime.now }.merge(stubs))) }
    end
  end
end
