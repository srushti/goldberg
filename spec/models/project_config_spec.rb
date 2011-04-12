require 'spec_helper'

describe ProjectConfig do

  context "default value" do
    let(:config) { ProjectConfig.new }

    it "for build frequency should be 20 seconds" do
      config.frequency.should == 20
    end
  end

end