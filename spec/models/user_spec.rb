require 'spec_helper'

describe User do
  describe "validations on login" do
    it "should be invalid for if user with login already exists" do
      user1 = Factory.create(:user, :login => "user")
      user2 = Factory.build(:user, :login => "user")
      user2.should have_at_least(1).error_on("login")
      user2.errors.full_messages.should include("Login has already been taken")
    end

    it "should be invalid without a login" do
      user = Factory.build(:user, :login => nil)
      user.should have_at_least(1).error_on("login")
      user.errors.full_messages.should include("Login can't be blank")
    end
  end

  describe "can_view" do
    it "should return true if user has viewing rights" do
      viewer = Factory.create(:viewer)
      user = viewer.user
      project = viewer.project
      user.can_view?(project).should be true
    end

    it "should return true if user has building rights" do
      builder = Factory.create(:builder)
      user = builder.user
      project = builder.project
      user.can_view?(project).should be true
    end

    it "should return false if user has no viewing or building rights" do
      user = Factory.create(:user)
      project = Factory.create(:project)
      user.can_view?(project).should be false
    end
  end

  describe "can_build" do
    it "should return true if user has building rights" do
      builder = Factory.create(:builder)
      user = builder.user
      project = builder.project
      user.can_build?(project).should be true
    end

    it "should return false if user has only viewing rights" do
      viewer = Factory.create(:viewer)
      user = viewer.user
      project = viewer.project
      user.can_build?(project).should be false
    end
  end
end
