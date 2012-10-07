require 'spec_helper'

describe Invitation do
  let(:user) { FactoryGirl.build(:user) }
  let(:invitee) { FactoryGirl.build(:user, login: "INVITEE", first_name: "Invited", last_name: "Person", email: "INVITEE@example.com") }

  subject { FactoryGirl.build(:invitation, user: user, invitee: invitee) }

  describe "validations" do
    it "should validate presence of user" do
      subject.user = nil
      subject.should_not be_valid
      subject.errors[:user].should include("can't be blank")
    end

    it "should validate presence of email or invitee" do
      subject.email = nil
      subject.invitee = nil # So it doesn't re-add the email_or_login
      subject.should_not be_valid
      subject.errors[:base].should include("Email and invitee can't both be blank")
    end

    it "should validate format of email" do
      ["invalid_email_or_login", "invalid@email_or_login", "invalid.email"].each do |invalid_email|
        subject.email = invalid_email
        subject.should_not be_valid
        subject.errors[:email].should include("is invalid")
      end

      ["valid@email.com", "valid.email@address.com", "valid.email@my.address.com"].each do |valid_email|
        subject.email = valid_email
        subject.valid?
        subject.errors[:email].should be_blank
      end
    end
  end

  describe "scopes and finders" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:invitee) { FactoryGirl.create(:user) }
    let!(:other_invitee) { FactoryGirl.create(:user) }

    let!(:invitation1) { FactoryGirl.create(:invitation, user: user, invitee: invitee) }
    let!(:invitation2) { FactoryGirl.create(:invitation, user: user, invitee: other_invitee) }
    let!(:other_invitation) { FactoryGirl.create(:invitation) }
    let!(:accepted) { FactoryGirl.create(:invitation, accepted: true) }
    let!(:rejected) { FactoryGirl.create(:invitation, accepted: false) }

    describe ".invited_by" do
      it "should return invitations where the given user is the user on the invitation" do
        invitations = Invitation.invited_by(user)
        invitations.length.should == 2
        invitations.should include(invitation1, invitation2)
      end
    end

    describe ".invited" do
      it "should return invitations where the given user is the invitee on the invitations" do
        Invitation.invited(invitee).should == [ invitation1 ]
      end
    end

    describe ".pending" do
      it "should return only invitations where accepted is nil" do
        invitations = Invitation.pending
        invitations.should have(3).invitations
        invitations.should include(invitation1, invitation2, other_invitation)
        invitations.all? { |inv| inv.accepted.nil? }.should be_true
      end
    end

    describe ".accepted" do
      it "should return only invitations where accepted is true" do
        invitations = Invitation.accepted
        invitations.should have(1).invitation
        invitations.should include(accepted)
      end
    end

    describe ".rejected" do
      it "should return only invitations where accepted is false" do
        invitations = Invitation.rejected
        invitations.should have(1).invitation
        invitations.should include(rejected)
      end
    end
  end

  describe "#generate_token" do
    it "should generate a token on create" do
      subject.token.should be_nil
      subject.save
      subject.token.should be_present
    end

    it "should not generate a token on subsequent saves" do
      subject.save.should be_true
      orig_token = subject.token
      orig_token.should be_present
      subject.email = "anewemail@example.com"
      subject.save.should be_true
      subject.token.should == orig_token
    end
  end

  describe "#invitee_display_name" do
    it "should display the invitee's full name if the invitee exists" do
      subject.invitee_display_name.should == "Invited Person"
    end

    it "should display the email if the invitee does not exist" do
      subject.invitee = nil
      subject.email = "INVITEE@example.com"
      subject.invitee_display_name.should == "INVITEE@example.com"
    end
  end

  describe "#simple_json" do
    it "should return a hash of simple attributes" do
      subject.save.should be_true
      subject.simple_json.should == {
        id: subject.id,
        token: subject.token,
        accepted: subject.accepted,
        user: subject.user.simple_json,
        invitee: subject.invitee.simple_json
      }
    end
  end
end
