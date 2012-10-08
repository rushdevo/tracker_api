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

    it "should validate presence of invitee if accepted" do
      subject.invitee = nil
      subject.accepted = true
      subject.should_not be_valid
      subject.errors[:invitee].should include("can't be blank")
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

  describe "#make_friends!" do
    it "should generate friendship records in both directions when accepted" do
      subject.accept!
      lambda { subject.save }.should change(Friendship, :count).by(2)
      user_friendship = Friendship.where(user_id: user.id).first
      user_friendship.should be_present
      user_friendship.friend.should == invitee
      friend_friendship = Friendship.where(user_id: invitee.id).first
      friend_friendship.should be_present
      friend_friendship.friend.should == user
    end

    it "should not generate additional friendship records the second time it is saved accepted" do
      subject.accept!
      subject.save.should be_true
      subject.invitee = FactoryGirl.create(:user)
      lambda { subject.save.should be_true }.should_not change(Friendship, :count)
    end

    it "should not generate friendship records when rejected" do
      subject.reject!
      lambda { subject.save.should be_true }.should_not change(Friendship, :count)
    end

    it "should have errors if friendship records can't be generated" do
      subject.accept!
      subject.invitee = nil
      # Hard to come up with a scenario where make_friends! would be called with invalid data, so just calling it directly
      lambda { subject.send(:make_friends!).should be_false }.should_not change(Friendship, :count)
      subject.errors[:base].should include("Can't create friendship: Friend can't be blank, User can't be blank")
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
