require "spec_helper"

module Goldberg
  describe Build do
    it "should be able to fake the last version" do
      Build.null.revision.should == 'HEAD'
      Build.null.should be_null
    end

    it "sorts correctly" do
      builds = [10, 9, 1, 500].map{|i| Factory(:build, :number => i)}
      builds.sort.map(&:number).map(&:to_i).should == [1, 9, 10, 500]
    end
  end
end
