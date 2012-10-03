require 'spec_helper'

describe Invitation do
  let(:user) { FactoryGirl.build(:user) }
  let(:invitee) { FactoryGirl.build(:user, login: "INVITEE", email: "INVITEE@example.com") }

  subject { FactoryGirl.build(:invitation, user: user, invitee: invitee, email_or_login: invitee.login) }

  describe "validations" do
    it "should validate presence of user" do
      subject.user = nil
      subject.should_not be_valid
      subject.errors[:user].should include("can't be blank")
    end

    it "should validate format of email_or_login" do
      subject.email_or_login = nil
      subject.invitee = nil # So it doesn't re-add the email_or_login
      subject.should_not be_valid
      subject.errors[:email_or_login].should include("can't be blank")
    end

    it "should validate format of email_or_login if invitee is blank" do
      subject.invitee = nil
      ["invalid_email_or_login", "invalid@email_or_login", "invalid.email"].each do |invalid_email|
        subject.email_or_login = invalid_email
        subject.should_not be_valid
        subject.errors[:email_or_login].should include("is invalid")
      end

      ["valid@email.com", "valid.email@address.com", "valid.email@my.address.com"].each do |valid_email|
        subject.email_or_login = valid_email
        subject.valid?
        subject.errors[:email_or_login].should be_blank
      end
    end
  end

  describe "#tie_invitation_to_user" do
    before do
      user.save!
      invitee.save!
    end

    it "should tie the invitation to the invitee if the login matches" do
      subject.invitee = nil
      subject.email_or_login = invitee.login.downcase
      subject.save.should be_true
      subject.invitee.should == invitee
    end

    it "should tie the invitation to the invitee if the email matches" do
      subject.invitee = nil
      subject.email_or_login = invitee.email.downcase
      subject.save.should be_true
      subject.invitee.should == invitee
    end

    it "should not be called on subsequent saves" do
      subject.save.should be_true
      subject.should_not_receive(:tie_invitation_to_user)
      subject.email_or_login = "changing something"
      subject.save.should be_true
    end
  end
end
