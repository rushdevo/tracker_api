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

  describe "#joining_user_id=(user_id)" do
    let(:joiner) { FactoryGirl.create(:user) }
    before { subject.save! }

    it "should create a UserGame for the given user" do
      lambda { subject.joining_user_id = joiner.id }.should change(UserGame, :count).by(1)
      user_game = UserGame.last
      user_game.user.should == joiner
      user_game.game.should == subject
    end

    it "should do nothing if the user is already a member of the game" do
      subject.user_games.create(user: joiner, game: subject)
      lambda { subject.joining_user_id = joiner.id }.should_not change(UserGame, :count)
    end

    it "should do nothing if user_id is nil" do
      lambda { subject.joining_user_id = nil }.should_not change(UserGame, :count)
    end

    it "should do nothing if user_id is an invalid user id" do
      lambda { subject.joining_user_id = 10000000 }.should_not change(UserGame, :count)
    end
  end

  describe "#leaving_user_id=(user_id)" do
    let(:leaver) { FactoryGirl.create(:user) }
    before do
      subject.save!
      subject.user_games.create(user: leaver, game: subject)
    end

    it "should remove the UserGame for the given user" do
      lambda { subject.leaving_user_id = leaver.id }.should change(UserGame, :count).by(-1)
      subject.users(true).should_not include(leaver)
    end

    it "should do nothing if the user is not already a member of the game" do
      other_leaver = FactoryGirl.create(:user)
      lambda { subject.leaving_user_id = other_leaver.id }.should_not change(UserGame, :count)
    end

    it "should do nothing if user_id is nil" do
      lambda { subject.leaving_user_id = nil }.should_not change(UserGame, :count)
    end

    it "should do nothing if user_id is an invalid user_id" do
      lambda { subject.leaving_user_id = 100000 }.should_not change(UserGame, :count)
    end
  end

  describe "#validate_params_for(user, params)" do
    let(:joiner) { FactoryGirl.create(:user) }
    let(:leaver) { FactoryGirl.create(:user) }
    let(:owner_params) { { 'start_time' => Time.zone.now+1.hour }.with_indifferent_access }
    let(:joining_params) { { 'joining_user_id' => joiner.id }.with_indifferent_access }
    let(:leaving_params) { { 'leaving_user_id' => leaver.id }.with_indifferent_access }

    it "should be true if the user is the owner" do
      subject.validate_params_for(subject.owner, owner_params).should be_true
    end

    it "should be true for any user if the params contains only params for joining the game" do
      subject.validate_params_for(joiner, joining_params).should be_true
    end

    it "should be true for any user if the params contains only params for leaving the game" do
      subject.validate_params_for(leaver, leaving_params).should be_true
    end

    it "should be false for a non-owner trying to modify the game" do
      subject.validate_params_for(joiner, owner_params).should be_false
    end

    it "should be false for a non owner trying to join someone else" do
      subject.validate_params_for(leaver, joining_params).should be_false
    end

    it "should be false for a non owner trying to leave for someone else" do
      subject.validate_params_for(joiner, leaving_params).should be_false
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
