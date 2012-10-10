class User < ActiveRecord::Base
  devise :database_authenticatable, :token_authenticatable, :registerable, :recoverable, :validatable

  has_many :games
  has_many :invitations
  has_many :invites, class_name: "Invitation", foreign_key: :invitee_id

  attr_accessible :email, :login, :password, :password_confirmation

  validates_presence_of :login
  validates_uniqueness_of :login

  before_save :reset_authentication_token, if: :encrypted_password_changed?

  scope :by_email_or_login, lambda { |email_or_login|
    where("email LIKE ? or login LIKE ?", "%#{email_or_login}%", "%#{email_or_login}%")
  }

  def clear_authentication_token!
    update_attribute(:authentication_token, nil)
  end

  def full_name
    if first_name.present? || last_name.present?
      "#{first_name} #{last_name}".strip
    else
      login
    end
  end

  def simple_json
    {
      id: id,
      login: login,
      email: email,
      first_name: first_name,
      last_name: last_name,
      full_name: full_name
    }
  end
end
