require 'spec_helper'

describe FriendshipsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:friendship1) { FactoryGirl.create(:friendship, user: user) }
  let!(:friendship2) { FactoryGirl.create(:friendship, friend: user) }
  let!(:other_friendship) { FactoryGirl.create(:friendship) }

  it_should_behave_like "requires authentication", { get: [:index, {}], delete: [:destroy, { id: 1}] }

  describe "#index" do
    it "should respond with json for the current user's friendships" do
      get :index, auth_token: user.authentication_token
      json = json_from_response(200, true)
      friendships = json['friendships']
      friendship = friendships.detect { |f| f['id'] == friendship1.id }
      compare_json_to_simple_json(friendship, friendship1)
      friendship = friendships.detect { |f| f['id'] == friendship2.id }
      compare_json_to_simple_json(friendship, friendship2)
    end
  end

  describe "#destroy" do
    it "should be a 401 if the current user does not belong to the friendship" do
      delete :destroy, auth_token: user.authentication_token, id: other_friendship.id
      json = json_from_response(401, false)
      json['message'].should == "You do not have permissions to unfriend this person"
    end

    it "should destroy a friendship" do
      delete :destroy, auth_token: user.authentication_token, id: friendship1.id
      response.should be_successful
      Friendship.find_by_id(friendship1.id).should be_nil
    end

    it "should respond with successful json" do
      delete :destroy, auth_token: user.authentication_token, id: friendship2.id
      json = json_from_response(200, true)
      json['message'].should == "You are no longer friends with #{friendship2.user.full_name}"
    end
  end
end
