require 'spec_helper'

describe AuthenticationTokensController do
  let(:password) { "P@ssw0rd" }
  let(:login) { "my_user_login" }
  let(:user) { FactoryGirl.create(:user, login: login, password: password, password_confirmation: password) }

  describe "#create" do
    it "should generate a token if authentication succeeds" do
      user.update_attribute(:authentication_token, nil)
      post :create, { login: login, password: password }
      response.should be_successful
      json = JSON.parse(response.body)
      json['success'].should be_true
      json['login'].should eql(login)
      token = json['auth_token']
      token.should be_present
      user.reload.authentication_token.should eql(token)
    end

    it "should change the token if authentication succeeds" do
      orig_token = user.authentication_token
      orig_token.should be_present
      post :create, { login: login, password: password }
      response.should be_successful
      json = JSON.parse(response.body)
      json['success'].should be_true
      json['login'].should eql(login)
      token = json['auth_token']
      token.should be_present
      user.reload.authentication_token.should eql(token)
      token.should_not eql(orig_token)
    end

    it "should respond with a 401 if there is no login" do
      post :create, { password: password }
      response.status.should eql(401)
      json = JSON.parse(response.body)
      json['success'].should eql(false)
      json['message'].should eql("Invalid login or password")
    end

    it "should respond with a 401 if there is no password" do
      post :create,  { login: login }
      response.status.should eql(401)
      json = JSON.parse(response.body)
      json['success'].should eql(false)
      json['message'].should eql("Invalid login or password")
    end

    it "should respond with a 401 if the password is incorrect" do
      post :create,  { login: login, password: "A Bad Password" }
      response.status.should eql(401)
      json = JSON.parse(response.body)
      json['success'].should eql(false)
      json['message'].should eql("Invalid login or password")
    end
  end

  describe "#destroy" do
    it "should unset the authentication token" do
      orig_token = user.authentication_token
      delete :destroy, { auth_token: orig_token }
      response.should be_successful
      json = JSON.parse(response.body)
      json['success'].should be_true
      user.reload.authentication_token.should be_nil
    end

    it "should respond with a 401 if the user is not authenticated" do
      # TODO: This isn't working. We are getting the response of a Response#to_s, instead of Response.body in the body
      # Need to test and see if this is a test-only issue, or if it's doing the same if curled (curl -X DELETE localhost:3000/authentication_token.json)
      # Is it a bug?
      delete :destroy, format: 'json'
      response.status.should eql(401)
      json = JSON.parse(response.body)
      json['success'].should eql(false)
      json['message'].should eql("You must authenticate to access this content")
    end
  end
end
