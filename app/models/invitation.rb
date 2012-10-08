class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :invitee, class_name: "User"

  validates_presence_of :user
  validates_format_of :email, with: User.email_regexp, allow_nil: true
  validates_presence_of :token
  validates_uniqueness_of :token
  validates_presence_of :invitee, if: :accepted?

  validate :validate_email_or_invitee

  before_validation :generate_token, on: :create
  before_save :make_friends!, if: lambda { |inv| inv.accepted_changed? && inv.accepted? }

  attr_accessible :user_id, :user, :invitee_id, :invitee, :email, :accepted

  scope :pending, lambda { where(accepted: nil) }
  scope :accepted, lambda { where(accepted: true) }
  scope :rejected, lambda { where(accepted: false) }

  # All invitations where the given user is the user on the invitation
  scope :invited_by, lambda { |user|
    where(user_id: user)
  }

  # All invitations where the given user is the invitee on the invitation
  scope :invited, lambda { |invitee|
    where(invitee_id: invitee)
  }

  def invitee_display_name
    invitee.present? ? invitee.full_name : email
  end

  def accepted?
    self.accepted == true
  end

  def rejected?
    self.accepted == false
  end

  def pending?
    self.accepted.nil?
  end

  def accept!
    self.accepted = true
  end

  def reject!
    self.accepted = false
  end

  def status_message
    if accepted?
      "Invitation has been accepted"
    elsif rejected?
      "Invitation has been rejected"
    else
      "Invitation is pending"
    end
  end

  def simple_json
    {
      id: id,
      user: user.try(:simple_json),
      invitee: invitee.try(:simple_json),
      token: token,
      accepted: accepted
    }
  end

protected
  def validate_email_or_invitee
    if email.blank? && invitee.blank?
      errors.add(:base, "Email and invitee can't both be blank")
    end
  end

  def generate_token
    while self.token.blank? || !Invitation.where(token: self.token).count.zero?
      self.token = Devise.friendly_token
    end
  end

  # Make friendship records in both directions
  def make_friends!
    friendships = [
      Friendship.new(user: user, friend: invitee),
      Friendship.new(user: invitee, friend: user)
    ]
    if friendships.all? { |f| f.save }
      true
    else
      friend_errors = friendships.map { |f| f.valid?; f.errors.full_messages }.flatten
      errors.add(:base, "Can't create friendship: #{friend_errors.join(', ')}")
      false
    end
  end
end
