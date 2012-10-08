require 'spec_helper'

describe Friendship do
  subject { FactoryGirl.build(:friendship) }

  describe "validations" do
    it "should validate presence of user" do
      subject.user = nil
      subject.should_not be_valid
      subject.errors[:user].should include("can't be blank")
    end

    it "should validate presence of friend" do
      subject.friend = nil
      subject.should_not be_valid
      subject.errors[:friend].should include("can't be blank")
    end
  end
end
