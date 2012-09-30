require 'spec_helper'

describe User do
  subject { FactoryGirl.create(:user) }

  describe "#reset_authentication_token" do
    it "should set the token if the password changes" do
      original_token = subject.authentication_token
      original_token.should be_present
      subject.password = subject.password_confirmation = "n3wP@ssw0rd"
      subject.save
      subject.authentication_token.should be_present
      subject.authentication_token.should_not equal(original_token)
    end

    it "should not reset the token if a non-password field changes" do
      original_token = subject.authentication_token
      original_token.should be_present
      subject.login = "anewlogin"
      subject.save
      subject.authentication_token.should equal(original_token)
    end
  end

  describe "validations" do
    describe "login" do
      it "should validate presence of login" do
        subject.login = nil
        subject.should_not be_valid
        subject.errors[:login].should include("can't be blank")
      end

      it "should validate uniqueness of login" do
        other = FactoryGirl.build(:user, login: subject.login)
        other.should_not be_valid
        other.errors[:login].should include("has already been taken")
      end
    end

    describe "password" do
      it "should require password confirmation" do
        subject.password = "anewpassword"
        subject.should_not be_valid
        subject.errors[:password].should include("doesn't match confirmation")
      end
    end
  end
end
