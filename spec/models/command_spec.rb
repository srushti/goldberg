require 'spec_helper'

describe Command do
  it "knows how to renice its process" do
    command = Command.new('sleep 1')
    command.execute_async
    command.renice!('+2')
    
    niceness_of(command).should eq('2')
  end
  
  def niceness_of(command)
    status = `ps -l #{command.pid}`
    headers, values = status.split("\n")
    niceness_column = headers.split(' ').map{|header| header.strip}.index('NI')
    values.split(' ').map{|value| value.strip}[niceness_column]
  end
end
