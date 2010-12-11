require 'spec_helper'

module GoldbergApi
  describe Application do
    it "should flap wings" do
      get '/'
      last_response.body.should == 'Butterfly'
    end
  end
end
