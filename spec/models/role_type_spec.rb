require 'spec_helper'

describe RoleType do
  describe "validations on name" do
    it "should be invalid for if role_type with name already exists" do
      role_type1 = Factory.create(:role_type, :name => "viewer")
      role_type2 = Factory.build(:role_type, :name => "viewer")
      role_type2.should have_at_least(1).error_on("name")
      role_type2.errors.full_messages.should include("Name has already been taken")
    end

    it "should be invalid without a name" do
      role_type = Factory.build(:role_type, :name => nil)
      role_type.should have_at_least(1).error_on("name")
      role_type.errors.full_messages.should include("Name can't be blank")
    end
  end
end
