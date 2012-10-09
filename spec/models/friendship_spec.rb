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

  describe "scopes and finders" do
    describe ".for_user(user)" do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:friendship1) { FactoryGirl.create(:friendship, user: user) }
      let!(:friendship2) { FactoryGirl.create(:friendship, friend: user) }
      let!(:other_friendship) { FactoryGirl.create(:friendship) }

      it "should return the friendships for that user" do
        friendships = Friendship.for_user(user)
        friendships.should include(friendship1, friendship2)
        friendships.should_not include(other_friendship)
      end
    end
  end

  describe "#simple_json" do
    it "should return a hash of basic attributes" do
      subject.save.should be_true
      subject.simple_json.should == {
        id: subject.id,
        user: subject.user.simple_json,
        friend: subject.friend.simple_json,
        invitation: nil
      }
    end
  end
end
