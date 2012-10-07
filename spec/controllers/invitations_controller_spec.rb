require 'spec_helper'

describe InvitationsController do
  let!(:user1) { FactoryGirl.create(:user) }
  let!(:user2) { FactoryGirl.create(:user) }
  let!(:invitation1) { FactoryGirl.create(:invitation, user: user1, invitee: user2) }
  let!(:invitation2) { FactoryGirl.create(:invitation, user: user2, invitee: user1) }
  let!(:accepted_invitation) { FactoryGirl.create(:invitation, user: user1, accepted: true) }
  let!(:rejected_invitation) { FactoryGirl.create(:invitation, invitee: user1, accepted: false) }

  it_should_behave_like "requires authentication", { get: [:index, {}], get: [:new, {}], post: [:create, {}], put: [:update, { id: 1}] }

  describe "#index" do
    it "should return successful json" do
      get :index, auth_token: user1.authentication_token
      json = json_from_response(200, true)
      json['invited_by'].should have(1).invitation
      compare_json_to_simple_json(json['invited_by'].first, invitation1)
      json['invited'].should have(1).invitation
      invited = json['invited'].first
      invited.with_indifferent_access.should == invitation2.simple_json.with_indifferent_access
    end
  end

  describe "#new" do
    it "should return unsuccessful json with no email or login" do
      get :new, auth_token: user1.authentication_token
      json = json_from_response(200, false)
      json['message'].should == "No users matched the given email or login"
    end

    it "should return unsuccessful json for a non-matching email or login" do
      get :new, auth_token: user1.authentication_token, email_or_login: "foo"
      json = json_from_response(200, false)
      json["message"].should == "No users matched the given email or login"
    end

    it "should return successful json with partial matching email" do
      get :new, auth_token: user1.authentication_token, email_or_login: user2.email[1..-2]
      json = json_from_response(200, true)
      json['users'].should have(1).user
      compare_json_to_simple_json(json['users'].first, user2)
    end

    it "should return successful json with full matching email" do
      get :new, auth_token: user1.authentication_token, email_or_login: user2.email
      json = json_from_response(200, true)
      json['users'].should have(1).user
      compare_json_to_simple_json(json['users'].first, user2)
    end

    it "should return succesful json with partial matching login" do
      get :new, auth_token: user1.authentication_token, email_or_login: user2.login[1..-1]
      json = json_from_response(200, true)
      json['users'].should have(1).user
      compare_json_to_simple_json(json['users'].first, user2)
    end

    it "should return successful json with full matching login" do
      get :new, auth_token: user1.authentication_token, email_or_login: user2.login
      json = json_from_response(200, true)
      json['users'].should have(1).user
      compare_json_to_simple_json(json['users'].first, user2)
    end
  end

  describe "#create" do
    let(:new_invitee) { FactoryGirl.create(:user) }
    let(:email) { "test@rushdevo.com" }

    it "should return a 401 if the user doesn't match the invitation's user" do
      post :create, auth_token: user1.authentication_token, invitation: { user_id: user2.id, invitee_id: new_invitee.id }
      json = json_from_response(401, false)
      json['message'].should == "You do not have permissions to create an invitation for this user"
    end

    it "should create an invitation with an invitee" do
      lambda {
        post :create, auth_token: user1.authentication_token, invitation: { user_id: user1.id, invitee_id: new_invitee.id }
      }.should change(Invitation, :count).by(1)
      invitation = Invitation.last
      invitation.user.should == user1
      invitation.invitee.should == new_invitee
      invitation.email.should be_nil
    end

    it "should create an invitation with an email" do
      lambda {
        post :create, auth_token: user1.authentication_token, invitation: { user_id: user1.id, email: email }
      }.should change(Invitation, :count).by(1)
      invitation = Invitation.last
      invitation.user.should == user1
      invitation.invitee.should be_nil
      invitation.email.should == "test@rushdevo.com"
    end

    it "should return successful json with an invitee" do
      post :create, auth_token: user1.authentication_token, invitation: { user_id: user1.id, invitee_id: new_invitee.id }
      json = json_from_response(200, true)
      json['message'].should == "Invitation sent to #{new_invitee.full_name}"
    end

    it "should return successful json with an email" do
      post :create, auth_token: user1.authentication_token, invitation: { user_id: user1.id, email: email }
      json = json_from_response(200, true)
      json['message'].should == "Invitation sent to #{email}"
    end

    it "should return unsuccessful json if validations fail" do
      post :create, auth_token: user1.authentication_token, invitation: { user_id: user1.id }
      json = json_from_response(200, false)
      json['message'].should == "Unable to save Invitation: Email and invitee can't both be blank"
    end
  end

  describe "#update" do
    it "should return a 401 if the user doesn't match the invitee" do
      put :update, id: invitation1.id, auth_token: user1.authentication_token, invitation: { accepted: true }
      json = json_from_response(401, false)
      json['message'].should == "You do not have permissions to accept or reject this invitation"
    end

    it "should accept an invitation" do
      invitation1.accepted.should be_nil
      put :update, id: invitation1.id, auth_token: user2.authentication_token, invitation: { accepted: true }
      invitation1.reload.should be_accepted
    end

    it "should reject an invitation" do
      invitation1.accepted.should be_nil
      put :update, id: invitation1.id, auth_token: user2.authentication_token, invitation: { accepted: false }
      invitation1.reload.should be_rejected
    end

    it "should return successful json for an accepted invitation" do
      invitation1.accepted.should be_nil
      put :update, id: invitation1.id, auth_token: user2.authentication_token, invitation: { accepted: true }
      json = json_from_response(200, true)
      json['message'].should == "Invitation has been accepted"
    end

    it "should return successful json for an rejected invitation" do
      invitation1.accepted.should be_nil
      put :update, id: invitation1.id, auth_token: user2.authentication_token, invitation: { accepted: false }
      json = json_from_response(200, true)
      json['message'].should == "Invitation has been rejected"
    end

    it "should return unsuccesful json if validations fail" do
      put :update, id: invitation1.id, auth_token: user2.authentication_token, invitation: { invitee_id: nil, email: nil }
      json = json_from_response(200, false)
      json['message'].should == "Unable to save Invitation: Email and invitee can't both be blank"
    end
  end
end