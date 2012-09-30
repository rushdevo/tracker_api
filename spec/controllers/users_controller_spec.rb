require 'spec_helper'

describe UsersController do
  let(:valid_user_params) { { user: { login: "test", email: "test@rushdevo.com", password: "password", password_confirmation: "password" } } }
  let(:invalid_user_params) {
    params = valid_user_params
    params[:user][:password_confirmation] = "wrong confirmation"
    params
  }

  describe "#create" do
    it "should create a new user when successful" do
      lambda {
        post :create, valid_user_params
      }.should change(User, :count).by(1)
      User.find_by_login("test").should be_present
    end

    it "should respond with valid json when successful" do
      post :create, valid_user_params
      response.should be_successful
      user = User.find_by_login("test")
      json = JSON.parse(response.body)
      json['success'].should == true
      json['auth_token'].should be_present
      json['auth_token'].should == user.authentication_token
      json['login'].should == "test"
      json['message'].should == "You have successfully created an account for test"
    end

    it "should not create a new user when unsuccessful" do
      lambda {
        post :create, invalid_user_params
      }.should_not change(User, :count)
    end

    it "should respond with valid json when unsuccessful" do
      post :create, invalid_user_params
      response.should be_successful
      json = JSON.parse(response.body)
      json['success'].should == false
      json['message'].should == "Unable to save User: Password doesn't match confirmation"
    end
  end

  describe "#update" do
    let(:user) { FactoryGirl.create(:user, valid_user_params[:user]) }

    it "should require authentication" do
      put :update, { user: { login: "anewlogin" } }
      response.status.should == 401
      user.reload.login.should == "test"
    end

    it "should udpate the user when successful" do
      put :update, { auth_token: user.authentication_token, user: { login: "anewlogin" } }
      response.should be_successful
      user.reload.login.should == "anewlogin"
    end

    it "should respond with valid json when successful" do
      put :update, { auth_token: user.authentication_token, user: { login: "anewlogin" } }
      response.should be_successful
      json = JSON.parse(response.body)
      user.reload
      json['success'].should == true
      json['auth_token'].should be_present
      json['auth_token'].should == user.authentication_token
      json['login'].should == "anewlogin"
      json['message'].should == "You have successfully updated the account for anewlogin"
    end

    it "should not update the user when unsuccessful" do
      put :update, { auth_token: user.authentication_token, user: { login: "anewlogin", password: "password1", password_confirmation: "password2"} }
      response.should be_successful
      user.reload.login.should == "test"
    end

    it "should respond with valid json when unsuccessful" do
      put :update, { auth_token: user.authentication_token, user: { login: "anewlogin", password: "password1", password_confirmation: "password2"} }
      response.should be_successful
      json = JSON.parse(response.body)
      user.reload
      json['success'].should == false
      json['message'].should == "Unable to save User: Password doesn't match confirmation"
    end
  end
end
