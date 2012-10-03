class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :invitee, class_name: "User"

  validates_presence_of :user, :email_or_login
  validates_format_of :email_or_login, with: User.email_regexp, unless: :invitee_id

  before_validation :tie_invitation_to_user, on: :create

protected
  # Find a matching email or login and tie the user to the invitee association
  def tie_invitation_to_user
    if self.invitee_id.blank? && self.email_or_login.present?
      self.invitee = User.where("email LIKE ? OR login LIKE ?", email_or_login, email_or_login).first
    end
  end
end
