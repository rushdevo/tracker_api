require 'spec_helper'

describe GamesController do
  let!(:owner) { FactoryGirl.create(:user) }
  let!(:participant) { FactoryGirl.create(:user) }
  let!(:non_participant) { FactoryGirl.create(:user) }
  let!(:game) { FactoryGirl.create(:game, owner: owner, joining_user_id: participant.id) }

  it_should_behave_like "requires authentication", { get: [:index, {}], post: [:create, {}], put: [:update, { id: 1}] }

  describe "#index" do
    it "should return json for all incomplete games for the current user" do
      complete_game = FactoryGirl.create(:game, joining_user_id: participant.id)
      complete_game.finish!
      other_game = FactoryGirl.create(:game)

      get :index, auth_token: participant.authentication_token
      json = json_from_response(200, true)
      json['games'].should have(1).game
      compare_json_to_simple_json(json['games'].first, game)
    end
  end

  describe "#create" do
    let(:start_time) { Time.zone.now + 10.minutes }

    it "should create a game owned by the current user" do
      lambda {
        post :create, auth_token: owner.authentication_token, game: { start_time: start_time }
      }.should change(Game, :count).by(1)
      Game.last.owner.should == owner
    end

    it "should respond with successful json" do
      post :create, auth_token: owner.authentication_token, game: { start_time: start_time }
      json = json_from_response(200, true)
      json['game']['start_time'].should == start_time.as_json
      compare_json_to_simple_json(json['game']['owner'], owner)
    end

    it "should respond with unsuccessful json" do
      # Not really any way to make an invalid game, so fake errors to test
      errors = Game.new.errors
      errors.add(:foo, "is invalid")
      Game.any_instance.stub(:valid?).and_return(false)
      Game.any_instance.stub(:errors).and_return(errors)

      post :create, auth_token: owner.authentication_token, game: { start_time: start_time }
      json = json_from_response(200, false)
      json['message'].should == "Unable to save Game: Foo is invalid"
    end
  end

  describe "#update" do
    let(:new_start_time) { game.start_time + 1.hour }

    it "should respond with a 401 if a participant tries to modify the game" do
      put :update, id: game.id, auth_token: participant.authentication_token, game: { start_time: new_start_time }
      json = json_from_response(401, false)
      json['message'].should == "You do not have permissions to modify this game"
    end

    it "should respond with a 401 if a non-participant tries to modify the game" do
      put :update, id: game.id, auth_token: non_participant.authentication_token, game: { start_time: new_start_time }
      json = json_from_response(401, false)
      json['message'].should == "You do not have permissions to modify this game"
    end

    it "should allow the owner to modify the game" do
      put :update, id: game.id, auth_token: owner.authentication_token, game: { start_time: new_start_time }
      game.reload.start_time.should be_within(1.second).of(new_start_time)
    end

    it "should allow a non-owner to join the game" do
      put :update, id: game.id, auth_token: non_participant.authentication_token, game: { joining_user_id: non_participant.id }
    end

    it "should not allow a non-participant to leave the game for someone else" do
      put :update, id: game.id, auth_token: non_participant.authentication_token, game: { leaving_user_id: participant.id }
      json = json_from_response(401, false)
      json['message'].should == "You do not have permissions to modify this game"
    end

    it "should allow a participant to leave the game" do
      lambda {
        put :update, id: game.id, auth_token: participant.authentication_token, game: { leaving_user_id: participant.id }
      }.should change(UserGame, :count).by(-1)
      game.users(true).should_not include(participant)
    end

    it "should respond with successful json" do
      put :update, id: game.id, auth_token: participant.authentication_token, game: { leaving_user_id: participant.id }
      json = json_from_response(200, true)
      compare_json_to_simple_json(json['game'], game.reload)
    end

    it "should respond with unsuccessful json" do
      # Not really any way to make an invalid game, so fake errors to test
      errors = Game.new.errors
      errors.add(:foo, "is invalid")
      Game.any_instance.stub(:valid?).and_return(false)
      Game.any_instance.stub(:errors).and_return(errors)

      put :update, id: game.id, auth_token: owner.authentication_token, game: { start_time: new_start_time }
      json = json_from_response(200, false)
      json['message'].should == "Unable to save Game: Foo is invalid"
    end
  end
end