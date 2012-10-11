require 'spec_helper'

describe UserGame do
  subject { FactoryGirl.build(:user_game) }

  describe "validations" do
    it "should validate that it has a user" do
      subject.user = nil
      subject.should_not be_valid
      subject.errors[:user].should include("can't be blank")
    end

    it "should validate that it has a game" do
      subject.game = nil
      subject.should_not be_valid
      subject.errors[:game].should include("can't be blank")
    end
  end
end
