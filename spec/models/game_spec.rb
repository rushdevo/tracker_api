require 'spec_helper'

describe Game do
  subject { FactoryGirl.build(:game) }

  describe "validations" do
    it "should validate presence of owner" do
      subject.owner = nil
      subject.should_not be_valid
      subject.errors[:owner].should include("can't be blank")
    end
  end

  describe "#default_start_time" do
    it "should set the start time to now if it is blank" do
      subject.start_time.should be_nil
      subject.save.should be_true
      subject.start_time.should be_present
      subject.start_time.should be_within(1.second).of(Time.zone.now)
    end

    it "should not set the start time if it is not blank" do
      subject.start_time = Time.zone.now + 5.hours
      lambda {
        subject.save.should be_true
      }.should_not change(subject, :start_time)
    end
  end

  describe "state machine" do
    it "should default to the pending state" do
      subject.state.should be_nil
      subject.save.should be_true
      subject.should be_pending
    end
  end

  describe "scopes and finders" do
    describe "state scopes" do
      let!(:pending_game) { FactoryGirl.create(:game, state: "pending") }
      let!(:in_progress_game) { FactoryGirl.create(:game, state: "in_progress") }
      let!(:complete_game) { FactoryGirl.create(:game, state: "complete") }

      describe ".pending" do
        it "should return only games who's state is 'pending'" do
          Game.pending.should == [pending_game]
        end
      end

      describe ".in_progress" do
        it "should return only games who's state is 'in_progress'" do
          Game.in_progress.should == [in_progress_game]
        end
      end

      describe ".complete" do
        it "should return only games who's state is 'complete'" do
          Game.complete.should == [complete_game]
        end
      end
    end

    describe ".owned_by(user)" do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:other_user) { FactoryGirl.create(:user) }
      let!(:game) { FactoryGirl.create(:game, owner: user) }
      let!(:other_game) { FactoryGirl.create(:game, owner: other_user) }

      it "should return only games owned by the given user" do
        Game.owned_by(user).should == [game]
      end
    end
  end
end
