require 'spec_helper'

describe PasswordsController do
  let(:user) { FactoryGirl.create(:user) }
  before { ActionMailer::Base.deliveries.clear }

  describe "#create" do
    it "should set the reset password token" do
      user.reset_password_token.should be_nil
      user.reset_password_sent_at.should be_nil
      post :create, user: { login: user.login }
      user.reload.reset_password_token.should be_present
      user.reload.reset_password_sent_at.should be_present
    end

    it "should send an email with password reset instructions" do
      lambda {
        post :create, user: { login: user.login }
      }.should change(ActionMailer::Base.deliveries, :length).from(0).to(1)

      user.reload.reset_password_token.should be_present

      mail = ActionMailer::Base.deliveries.last
      mail.from.should == [AuthMailer::DO_NOT_REPLY]
      mail.to.should == [user.email]
      mail.subject.should == "Tracker: Reset password instructions"

      mail.body.should include("Hello #{user.login}!")
      mail.body.should include("Someone has requested to reset your password for the Tracker mobile app.")
      mail.body.should include("If you didn't make that request, please ignore this email, and no change will be made to your password.")
      mail.body.should include("From your mobile phone with the app installed, you can click the following link to change your password:")
      mail.body.should include("Change my password")
      mail.body.should include(user.reset_password_token)
      mail.body.should include("Happy Tracking!")
    end

    it "should respond with valid json" do
      post :create, user: { login: user.login }
      response.should be_successful
      json = JSON.parse(response.body)
      json['success'].should == true
      json['email'].should == user.email
      json['message'].should == "An email has been sent with password reset instructions"
    end
  end

  describe "#update" do
    before do
      user.reset_password_token = "abcdefg"
      user.reset_password_sent_at = Time.zone.now
      user.save(validate: false)
    end
    let(:password_params) { { password: "newpassword", password_confirmation: "newpassword" } }
    let(:complete_params) { { user: password_params.merge(reset_password_token: user.reset_password_token) } }

    it "should not allow the update without the reset password token" do
      put :update, user: password_params
      response.should be_successful
    end

    it "should not allow the update with an invalid reset password token" do
      params = complete_params
      params[:user][:reset_password_token] = "invalidtoken"
      put :update, params
      response.should be_successful
      json = JSON.parse(response.body)
      json['success'].should == false
      json['message'].should == "Unable to save User: Reset password token is invalid"
      user.reload
      user.valid_password?("newpassword").should be_false
    end

    it "should update the password if the reset password token is present" do
      put :update, complete_params
      response.should be_successful
      user.reload
      user.valid_password?("newpassword").should be_true
    end

    it "should blank out the reset password token after the password has been changed" do
      put :update, complete_params
      response.should be_successful
      user.reload
      user.reset_password_token.should be_nil
      user.reset_password_sent_at.should be_nil
    end

    it "should respond with valid json" do
      put :update, complete_params
      response.should be_successful
      json = JSON.parse(response.body)
      json['success'].should == true
      json['message'].should == "Password reset for #{user.login}"
    end
  end
end