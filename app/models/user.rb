class User < ActiveRecord::Base
  devise :database_authenticatable, :token_authenticatable, :registerable, :recoverable, :validatable

  attr_accessible :email, :login, :password, :password_confirmation

  validates_presence_of :login
  validates_uniqueness_of :login

  before_save :reset_authentication_token, if: :encrypted_password_changed?

  def clear_authentication_token!
    update_attribute(:authentication_token, nil)
  end
end
