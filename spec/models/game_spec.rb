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

  describe "#make_owner_participate" do
    it "should make the owner be a participant on creation" do
      subject.should be_new_record
      subject.owner.should be_present
      subject.users.should be_empty
      lambda { subject.save }.should change(UserGame, :count).by(1)
      subject.users(true).should include(subject.owner)
    end

    it "should not be called on subsequent saves" do
      subject.save
      subject.should_not_receive(:make_owner_participate) do
        subject.start_time = Time.zone.now + 5.minutes
        subject.save
      end
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

      describe ".incomplete" do
        it "should return pending or in_progress games" do
          Game.incomplete.should include_only(pending_game, in_progress_game)
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

    describe ".for_user(user)" do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:game) {
        g = FactoryGirl.create(:game)
        g.user_games.create(user: user)
        g
      }
      let!(:other_game) { FactoryGirl.create(:game) }

      it "should return only games that the user belongs to" do
        Game.for_user(user).should == [game]
      end
    end
  end

  describe "#simple_json" do
    let(:participant) { FactoryGirl.create(:user) }
    let(:owner) { subject.owner }

    before do
      subject.user_games.build(user: participant, game: subject)
      subject.save.should be_true
    end

    it "should return a hash of basic attributes" do
      subject.simple_json.should == {
        id: subject.id,
        start_time: subject.start_time,
        state: subject.state,
        owner: subject.owner.simple_json,
        users: [participant.simple_json, owner.simple_json]
      }
    end
  end
end
