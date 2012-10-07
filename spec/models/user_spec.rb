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

  describe "scopes and finders" do
    describe ".by_email_or_login(email_or_login)" do
      let!(:other_user) { FactoryGirl.create(:user, login: "blahblah", email: "foobar@rushdevo.com") }

      it "should find with a partial matching email" do
        users = User.by_email_or_login(other_user.email[2..-2])
        users.should have(1).user
        users.first.should == other_user
      end

      it "should find with a fully matching email" do
        users = User.by_email_or_login(other_user.email)
        users.should have(1).user
        users.first.should == other_user
      end

      it "should find with a partial matching login" do
        users = User.by_email_or_login(other_user.login[2..-2])
        users.should have(1).user
        users.first.should == other_user
      end

      it "should find with a fully matching login" do
        users = User.by_email_or_login(other_user.login)
        users.should have(1).user
        users.first.should == other_user
      end
    end
  end

  describe "#full_name" do
    it "should be the last name if only last name is present" do
      subject.first_name = nil
      subject.last_name = "Last"
      subject.full_name.should == "Last"
    end

    it "should be the first name if only the first name is present" do
      subject.first_name = "First"
      subject.last_name = nil
      subject.full_name.should == "First"
    end

    it "should be the first and last name if they are both present" do
      subject.first_name = "First"
      subject.last_name = "Last"
      subject.full_name.should == "First Last"
    end

    it "should be the login if first and last name are blank" do
      subject.first_name = nil
      subject.last_name = nil
      subject.login = "login"
      subject.full_name.should == "login"
    end
  end

  describe "#simple_json" do
    it "should return a hash of basic attributes" do
      subject.save.should be_true
      subject.simple_json.should == {
        id: subject.id,
        login: subject.login,
        email: subject.email,
        first_name: subject.first_name,
        last_name: subject.last_name,
        full_name: subject.full_name
      }
    end
  end
end
